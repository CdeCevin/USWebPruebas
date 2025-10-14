from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator
from django.shortcuts import render,redirect
from incident.models import Incident
from department.models import Deparment
from management.models import Management
from poll.models import Poll
from registration.models import Profile
from core.utils import *
from manuals.models import Manuals

from django.http import HttpResponse
import xlwt

@login_required
def incident_list_active(request,page=None):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    profiles = Profile.objects.get(user_id = request.user.id)    
    manuals_list = Manuals.objects.filter(manual_name = 'Manual Incidente').first
    try:
        if page == None:
            page = request.GET.get('page')
        else:
            page = page
        if request.GET.get('page') == None:
            page = page
        else:
            page = request.GET.get('page')

        if flow == 1:
            department_activate_list = Deparment.objects.filter(state='Activo').order_by('deparment_name')
        if flow == 2:
            department_activate_list = []
        #Incidencias Activas
        incident_activate = Incident.objects.filter(state='Activo').order_by('name')
        page = request.GET.get('page')
        paginator = Paginator(incident_activate, QUANTITY_LIST) 
        incident_activate_list = paginator.get_page(page)
        management_activate_list = Management.objects.filter(state='Activo').order_by('management_name')
        # Acceder al nombre del departamento en cada incidente activo
        for management in management_activate_list:
            management.departments = list(Deparment.objects.filter(management=management, state='Activo').values('id', 'deparment_name'))
        if flow == 1:
            template_name = 'incident/incident_list_active.html'    
        if flow == 2:
            template_name = 'incident/incident_list_active2.html'           
        return render(request,template_name,{'username': request.user.username,'incident_activate_list':incident_activate_list,'department_activate_list': department_activate_list,'flow':flow,'profiles':profiles,'page':page,'paginator':paginator,'management_activate_list':management_activate_list,'management.departments':management.departments, 'manuals_list': manuals_list})
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')  
@login_required
def incident_list_deactive(request,page=None):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    profiles = Profile.objects.get(user_id = request.user.id)    
    try:
        if page == None:
            page = request.GET.get('page')
        else:
            page = page
        if request.GET.get('page') == None:
            page = page
        else:
            page = request.GET.get('page')  
        # Filtra las encuestas desactivadas y ordénalas por nombre
        incident_deactivate = Incident.objects.filter(state='Bloqueado').order_by('name')
        # Paginación
        paginator = Paginator(incident_deactivate , QUANTITY_LIST)
        incident_deactivate_list = paginator.get_page(page)
        template_name = 'incident/incident_list_deactive.html'    
        return render(request, template_name, {'profiles': profiles, 'incident_deactivate_list': incident_deactivate_list, 'page': page, 'username': request.user.username,'flow':flow,'paginator':paginator})
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')  
@login_required
def incident_add(request):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:     
        if request.method == 'POST':
            management_id = request.POST.get('management_id')
            name_incident = request.POST.get('name_incident')
            if name_incident == '' or management_id == '':
                messages.warning(request, 'Debe ingresar toda la información')
                return redirect('incident_list_active')   
            flow = type_flow(request)
            if flow == 1:
                department_id =request.POST.get('department_id')
                department_count = Deparment.objects.filter(pk=department_id).count()
                if department_count <= 0:
                    messages.error(request, 'Error en el deparatamento asociado')
                    return redirect('incident_list_active')   
            if flow == 2:
                department_id = 0   
            management_count = Management.objects.filter(pk=management_id).count()
            if management_count <= 0:
                messages.error(request, 'Hubo un error al crear una incidencia')
                return redirect('check_group_main')   
            
            incident_exist=Incident.objects.filter(name=name_incident.title())
            if incident_exist:
                messages.error(request, 'Error al crear el incidente. El nombre ya existe')
                return redirect('incident_list_active')
            
            incident_save = Incident(
                user_id = request.user.id,
                management_id = management_id,
                deparment_id = department_id,
                name = name_incident.title(),
                )
            incident_save.save()

            messages.success(request, 'Incidencia creada')
            return redirect('incident_list_active')  
        else:
            messages.error(request, 'Hubo un error, favor contactese con los administradores')
            return redirect('check_group_main')          
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')    

@login_required
def incident_block(request,incident_id):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:  
        #valido que la encuesta existe y se encuentre en estado creacion
        incident_count = Incident.objects.filter(pk=incident_id).count()
        if incident_count == 0:
            messages.error(request, 'Hubo un error al crear la nueva encuesta')
            return redirect('incident_list_active')

        poll_count = Poll.objects.filter(incident_id=incident_id).filter(state='Activo').count()
        if poll_count > 0:
            messages.error(request, 'No es posible bloquear esta incidencia ya que tiene encuestas activas')
            return redirect('incident_list_active')

        Incident.objects.filter(pk=incident_id).update(state='Bloqueado')
        messages.success(request, 'Incidente desactivado')       
        return redirect('incident_list_active')
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')   
@login_required
def incident_activate(request, incident_id):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:  
        #valido que la encuesta existe y se encuentre en estado creacion
        incident_count = Incident.objects.filter(pk=incident_id).count()
        if incident_count == 0:
            messages.error(request, 'Hubo un error al crear la incidencia')
            return redirect('poll_activate_list')    
        Incident.objects.filter(pk=incident_id).update(state='Activo')
        messages.success(request, 'Incidente activado')       
        return redirect('incident_list_deactive')
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')  
@login_required
def incident_edit(request,incident_id):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    profiles = Profile.objects.get(user_id = request.user.id)  
    try:
        incident_count = Incident.objects.filter(pk=incident_id).count()
        if incident_count <= 0:
            messages.error(request, 'Hubo un error al editar una incidencia')
            return redirect('check_group_main')   
        management_activate_list = Management.objects.filter(state='Activo').order_by('management_name')
        if flow == 1:
            department_activate_list = Deparment.objects.filter(state='Activo').order_by('deparment_name')
        if flow == 2:
            department_activate_list = []
        incident_data = Incident.objects.get(pk=incident_id)
        template_name = 'incident/incident_edit.html'    
        return render(request,template_name,{'username': request.user.username,'department_activate_list':department_activate_list,'incident_data':incident_data,'flow':flow,'profiles':profiles,'management_activate_list':management_activate_list})
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main') 
@login_required
def incident_edit_save(request):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:  
        if request.method == 'POST':
            incident_id = request.POST.get('id_incident')            
            management_id = request.POST.get('management_id')
            name_incident = request.POST.get('name_incident')
            if name_incident == '' or management_id == '' or incident_id == '':
                messages.warning(request, 'Debe ingresar toda la información')
                return redirect('incident_list_active')   
            incident_count = Incident.objects.filter(pk=incident_id).count()
            if incident_count <= 0:
                messages.error(request, 'Hubo un error al editar una incidencia')
                return redirect('check_group_main')  
            flow = type_flow(request)
            if flow == 1:
                department_id =request.POST.get('department_id')
                department_count = Deparment.objects.filter(pk=department_id).count()
                if department_count <= 0:
                    messages.error(request, 'Error en el deparatamento asociado')
                    return redirect('incident_list_active')   
            if flow == 2:
                department_id = 0   
            management_count = Management.objects.filter(pk=management_id).count()
            if management_count <= 0:
                messages.error(request, 'Hubo un error al editar una incidencia')
                return redirect('check_group_main')              
            Incident.objects.filter(pk=incident_id).update(management_id = management_id)
            Incident.objects.filter(pk=incident_id).update(deparment_id = department_id)

            Incident.objects.filter(pk=incident_id).update(name = name_incident.title())        
            messages.success(request, 'Incidencia editada')
            return redirect('incident_list_active',incident_id)  
        else:
            messages.error(request, 'Hubo un error, favor contactese con los administradores')
            return redirect('check_group_main')          
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')    

@login_required
def incident_8010(request,page=None):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    profiles = Profile.objects.get(user_id = request.user.id)    
    try:
        if page == None:
            page = request.GET.get('page')
        else:
            page = page
        if request.GET.get('page') == None:
            page = page
        else:
            page = request.GET.get('page')

        if flow == 1:
            department_activate_list = Deparment.objects.filter(state='Activo').order_by('deparment_name')
        if flow == 2:
            department_activate_list = []
        #Incidencias Activas
        incident_activate = Incident.objects.filter(state='Activo').order_by('name')
        page = request.GET.get('page')
        paginator = Paginator(incident_activate, QUANTITY_LIST) 
        incident_activate_list = paginator.get_page(page)
        management_activate_list = Management.objects.filter(state='Activo').order_by('management_name')
        for management in management_activate_list:
            management.departments = list(Deparment.objects.filter(management=management, state='Activo').values('id', 'deparment_name'))
        template_name = 'incident/incident_8010.html'    
        return render(request,template_name,{'username': request.user.username,'incident_activate_list':incident_activate_list,'department_activate_list': department_activate_list,'flow':flow,'profiles':profiles,'page':page,'paginator':paginator,'management_activate_list':management_activate_list,'management.departments':management.departments})
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')  
    

@login_required
# Reporte de excel activas
def report_incident_active(request):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        list_active = Incident.objects.filter(state = 'Activo').order_by('name')
        response = HttpResponse(content_type = 'application/ms-excel')
        response['Content-Disposition'] = 'attachment; filename="ReporteIncidentesActivos.xls"'
        wb = xlwt.Workbook(encoding='utf-8')
        ws = wb.add_sheet('Activos')
        row_num = 0
        columns = ['Incidencia', 'Dirección', 'Departamento']
        font_style = xlwt.XFStyle()
        font_style.font.bold = True

        for col_num in range(len(columns)):
            ws.write(row_num, col_num, columns[col_num], font_style)

        font_style = xlwt.XFStyle()

        ws.col(0).width = 256 * 40
        ws.col(1).width = 256 * 40
        ws.col(2).width = 256 * 40 
 

        for incident in list_active:
            row_num += 1
            ws.write(row_num, 0, incident.name, font_style)
            ws.write(row_num, 1, incident.management.management_name, font_style)
            ws.write(row_num, 2, incident.deparment.deparment_name, font_style)
            
        wb.save(response)
        return response
    
    except Exception as e:
        print(f"Error generating report: {str(e)}")
        messages.add_message(request, messages.INFO, f'Error al generar el reporte: {str(e)}')
        return redirect('incident_list_actives')

@login_required
# Reporte de excel desactivas
def report_incident_deactive(request):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        list_active = Incident.objects.filter(state = 'Bloqueado').order_by('name')
        response = HttpResponse(content_type = 'application/ms-excel')
        response['Content-Disposition'] = 'attachment; filename="ReporteIncidentesDesactivos.xls"'
        wb = xlwt.Workbook(encoding='utf-8')
        ws = wb.add_sheet('Desactivos')
        row_num = 0
        columns = ['Incidencia', 'Dirección', 'Departamento']
        font_style = xlwt.XFStyle()
        font_style.font.bold = True

        for col_num in range(len(columns)):
            ws.write(row_num, col_num, columns[col_num], font_style)

        font_style = xlwt.XFStyle()

        ws.col(0).width = 256 * 40
        ws.col(1).width = 256 * 40
        ws.col(2).width = 256 * 40 
 

        for incident in list_active:
            row_num += 1
            ws.write(row_num, 0, incident.name, font_style)
            ws.write(row_num, 1, incident.management.management_name, font_style)
            ws.write(row_num, 2, incident.deparment.deparment_name, font_style)
            
        wb.save(response)
        return response
    
    except Exception as e:
        print(f"Error generating report: {str(e)}")
        messages.add_message(request, messages.INFO, f'Error al generar el reporte: {str(e)}')
        return redirect('incident_list_actives')