from django.contrib import messages
from django.contrib.auth.models import User
from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator
from django.http import HttpResponse
from django.shortcuts import render,redirect,get_object_or_404
from incident.models import Incident
from department.models import Deparment
from management.models import Management
from registration.models import Profile
from core.utils import *
from poll.models import Request
from manuals.models import Manuals

import xlwt

@login_required
def department_list_active(request,page=None):    
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    profiles = Profile.objects.get(user_id = request.user.id) 
    manuals_list = Manuals.objects.filter(manual_name = 'Manual Departamento').first
    if flow == 2:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
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
            management_list = Management.objects.filter(state='Activo').order_by('management_name')
        if flow == 2:
            management_list = []
        department_activate = Deparment.objects.filter(state='Activo').order_by('deparment_name')
        page = request.GET.get('page')
        paginator = Paginator(department_activate , QUANTITY_LIST)
        department_activate_list = paginator.get_page(page)
        template_name = 'department/department_list_active.html'    
        return render(request, template_name, {'department_activate_list':department_activate_list,'username': request.user.username,'flow':flow,'profiles':profiles,'management_list':management_list,page:'page','paginator':paginator, 'manuals_list': manuals_list})
    except:
        messages.error(request, 'Hubo un error, revise si ha creado direcciones, si el error persiste, favor contactese con los administradores')
        return redirect('check_group_main')  
@login_required
def department_list_deactive(request,page=None):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    profiles = Profile.objects.get(user_id = request.user.id) 
    if flow == 2:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
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
        department_deactivate = Deparment.objects.filter(state='Bloqueado').order_by('deparment_name')
        # Paginación
        paginator = Paginator(department_deactivate , QUANTITY_LIST)
        department_deactivate_list = paginator.get_page(page)
        template_name = 'department/department_list_deactive.html'    
        return render(request,template_name,{'username': request.user.username,'department_deactivate_list':department_deactivate_list,'flow':flow,'profiles':profiles,page:'page','paginator':paginator})
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main') 
@login_required
def department_add(request):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    if flow == 2:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:   
        if request.method == 'POST':
            deparment_name = request.POST.get('deparment_name').title()
            deparment_in_charge = request.POST.get('deparment_in_charge').title()
            deparment_in_charge_mail = request.POST.get('deparment_in_charge_mail').upper()
            if deparment_name == '' or deparment_in_charge == '' or deparment_in_charge_mail == '':
                messages.warning(request, 'Debe ingresar toda la información')
                return redirect('department_list_active')   
            # Verificar si el nombre ya está registrado
            if Deparment.objects.filter(deparment_name=deparment_name).exists():
                messages.warning(request, 'El nombre ingresado ya está registrado')
                return redirect('department_list_active')
            management_id =request.POST.get('management_id')
            management_count = Management.objects.filter(pk=management_id).count()
            if management_count <= 0:
                messages.error(request, 'Error en la dirección asociada')
                return redirect('department_list_active')   
            deparment_save = Deparment(
                user_id = request.user.id,
                management_id = management_id,
                deparment_name = deparment_name,
                deparment_in_charge = deparment_in_charge,                
                deparment_in_charge_mail = deparment_in_charge_mail, 
                )
            deparment_save.save()
            messages.success(request, 'Departamento ingresado')
            return redirect('department_list_active')  
        else:
            messages.error(request, 'Hubo un error, favor contactese con los administradores')
            return redirect('check_group_main')         
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')    
    

@login_required
def department_block(request,department_id):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    if flow == 2:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:  
        #valido que la encuesta existe y se encuentre en estado creacion
        department_count = Deparment.objects.filter(pk=department_id).count()
        if department_count == 0:
            messages.error(request, 'Hubo un error al crear la nueva encuesta')
            return redirect('department_activate_list')    
        incident_count = Incident.objects.filter(deparment_id=department_id).filter(state='Activo').count()
        if incident_count > 0:
            messages.error(request, 'No es posible bloquear este departamento ya que tiene incidencias activas')
            return redirect('department_list_active')           
        
        Deparment.objects.filter(pk=department_id).update(state='Bloqueado')
        messages.success(request, 'Departamento desactivado')
        return redirect('department_list_active')
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')    
    
@login_required
def department_activate(request, department_id):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    if flow == 2:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')

    try:  
        department = get_object_or_404(Deparment, pk=department_id, state='Bloqueado')
        department.state = 'Activo'
        department.save()

        messages.success(request, 'Departamento activado')
        return redirect('department_list_deactive')
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')    
@login_required
def department_edit(request,department_id): 
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    profiles = Profile.objects.get(user_id = request.user.id) 
    if flow == 2:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:   
        management_list = Management.objects.filter(state='Activo').order_by('management_name')
        department_count = Deparment.objects.filter(pk=department_id).count()
        if department_count <= 0:
            messages.error(request, 'Hubo un error al editar un departamento')
            return redirect('check_group_main')        
        department_data = Deparment.objects.get(pk=department_id)
        department_user_data = User.objects.get(pk=department_data.user_id)
        template_name = 'department/department_edit.html'    
        return render(request,template_name,{'username': request.user.username,'department_data':department_data,'department_user_data':department_user_data,'flow':flow,'profiles':profiles,'management_list':management_list})
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')    
@login_required
def department_edit_save(request): 
    session = int(check_profile_admin(request))
    if session == 0:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    if flow == 2:
        messages.error(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:   
        if request.method == 'POST':
            department_id = request.POST.get('department_id')
            deparment_name = request.POST.get('deparment_name')
            deparment_in_charge = request.POST.get('deparment_in_charge')
            deparment_in_charge_mail = request.POST.get('deparment_in_charge_mail')
            department_count = Deparment.objects.filter(pk=department_id).count()
            if department_count <= 0:
                messages.error(request, 'Hubo un error al editar un departamento')
                return redirect('check_group_main') 
            if deparment_name == '' or deparment_in_charge == '' or deparment_in_charge_mail == '':
                messages.warning(request, 'Debe ingresar toda la información')
                return redirect('department_edit',department_id)   
            management_id =request.POST.get('management_id')
            management_count = Management.objects.filter(pk=management_id).count()
            if management_count <= 0:
                messages.error(request, 'Error en la dirección asociada')
                return redirect('department_edit',department_id)  
            Deparment.objects.filter(pk=department_id).update(deparment_name = deparment_name.title()) 
            Deparment.objects.filter(pk=department_id).update(deparment_in_charge = deparment_in_charge.title()) 
            Deparment.objects.filter(pk=department_id).update(deparment_in_charge_mail = deparment_in_charge_mail.upper()) 
            Deparment.objects.filter(pk=department_id).update(management_id = management_id)    
            messages.success(request, 'Departamento editado con éxito')
            return redirect('department_list_active',department_id) 
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main') 
    
@login_required
# Reporte de excel activas
def report_department_actives(request):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        list_active = Deparment.objects.filter(state = 'Activo').order_by('deparment_name')
        response = HttpResponse(content_type = 'application/ms-excel')
        response['Content-Disposition'] = 'attachment; filename="ReporteDepartamentosActivos.xls"'
        wb = xlwt.Workbook(encoding='utf-8')
        ws = wb.add_sheet('Activos')
        row_num = 0
        columns = ['Departamento', 'Encargado', 'Correo', 'Dirección']
        font_style = xlwt.XFStyle()
        font_style.font.bold = True

        for col_num in range(len(columns)):
            ws.write(row_num, col_num, columns[col_num], font_style)

        font_style = xlwt.XFStyle()

        ws.col(0).width = 256 * 40
        ws.col(1).width = 256 * 30
        ws.col(2).width = 256 * 30 
        ws.col(3).width = 256 * 40 

        for department in list_active:
            row_num += 1
            ws.write(row_num, 0, department.deparment_name, font_style)
            ws.write(row_num, 1, department.deparment_in_charge, font_style)
            ws.write(row_num, 2, department.deparment_in_charge_mail, font_style)
            ws.write(row_num, 3, department.management.management_name, font_style)

        wb.save(response)
        return response
    
    except Exception as e:
        print(f"Error generating report: {str(e)}")
        messages.add_message(request, messages.INFO, f'Error al generar el reporte: {str(e)}')
        return redirect('deparment_list_actives')
    

@login_required
# Reporte de excel desactivas
def report_department_deactives(request):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        list_active = Deparment.objects.filter(state = 'Bloqueado').order_by('deparment_name')
        response = HttpResponse(content_type = 'application/ms-excel')
        response['Content-Disposition'] = 'attachment; filename="ReporteDepartamentosDesactivos.xls"'
        wb = xlwt.Workbook(encoding='utf-8')
        ws = wb.add_sheet('Desactivos')
        row_num = 0
        columns = ['Departamento', 'Encargado', 'Correo', 'Dirección']
        font_style = xlwt.XFStyle()
        font_style.font.bold = True

        for col_num in range(len(columns)):
            ws.write(row_num, col_num, columns[col_num], font_style)

        font_style = xlwt.XFStyle()

        ws.col(0).width = 256 * 40
        ws.col(1).width = 256 * 30
        ws.col(2).width = 256 * 30 
        ws.col(3).width = 256 * 40 

        for department in list_active:
            row_num += 1
            ws.write(row_num, 0, department.deparment_name, font_style)
            ws.write(row_num, 1, department.deparment_in_charge, font_style)
            ws.write(row_num, 2, department.deparment_in_charge_mail, font_style)
            ws.write(row_num, 3, department.management.management_name, font_style)

        wb.save(response)
        return response
    
    except Exception as e:
        print(f"Error generating report: {str(e)}")
        messages.add_message(request, messages.INFO, f'Error al generar el reporte: {str(e)}')
        return redirect('deparment_list_deactives')
