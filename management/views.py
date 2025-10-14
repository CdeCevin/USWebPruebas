from django.contrib import messages
from django.contrib.auth.models import User
from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator
from django.shortcuts import render,redirect,get_object_or_404

from management.models import Management
from registration.models import Profile
from department.models import Deparment
from incident.models import Incident
from core.utils import *
from poll.models import Request, Poll, Fields
from manuals.models import Manuals

from django.http import HttpResponse
import xlwt

@login_required
def management_list_active(request,page=None):    
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    profiles = Profile.objects.get(user_id = request.user.id)
    manuals_list = Manuals.objects.filter(manual_name = 'Manual Dirección').first
    try:
        if page == None:
            page = request.GET.get('page')
        else:
            page = page
        if request.GET.get('page') == None:
            page = page
        else:
            page = request.GET.get('page')
        management_activate = Management.objects.filter(state='Activo').order_by('management_name')
        page = request.GET.get('page')
        paginator = Paginator(management_activate , QUANTITY_LIST)
        management_activate_list = paginator.get_page(page)
        template_name = 'management/management_list_active.html'    
        return render(request, template_name, {'management_activate_list':management_activate_list,'username': request.user.username,'flow':flow,'profiles':profiles,'page':page,'paginator':paginator, 'manuals_list': manuals_list})
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')       
@login_required
def management_list_block(request,page=None):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
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
        management_block = Management.objects.filter(state='Bloqueado').order_by('management_name')
        page = request.GET.get('page')
        paginator = Paginator(management_block , QUANTITY_LIST)
        management_block_list = paginator.get_page(page)
        template_name = 'management/management_list_block.html'    
        return render(request, template_name, {'management_block_list':management_block_list,'username': request.user.username,'flow':flow,'profiles':profiles,'page':page,'paginator':paginator})
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')    
@login_required
def management_add(request):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        if request.method == 'POST':
            management_name = request.POST.get('management_name').title()
            management_in_charge = request.POST.get('management_in_charge').title()
            management_in_charge_mail = request.POST.get('management_in_charge_mail').upper()
            if management_name == '' or management_in_charge == '' or management_in_charge_mail == '':
                messages.warning(request, 'Debe ingresar toda la información')
                return redirect('management_list_active')
            # Verificar si el nombre ya está registrado
            if Management.objects.filter(management_name=management_name).exists():
                messages.warning(request, 'El nombre ingresado ya está registrado')
                return redirect('management_list_active')
            management_save = Management(
                user_id = request.user.id,
                management_name = management_name,
                management_in_charge = management_in_charge,                
                management_in_charge_mail = management_in_charge_mail,                
                )
            management_save.save()
            messages.success(request, 'Dirección agregada')
            return redirect('management_list_active')  
        else:
            messages.error(request, 'Hubo un error, favor contactese con los administradores')
            return redirect('check_group_main')       
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')       
@login_required
def management_block(request,management_id):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        management_count = Management.objects.filter(pk=management_id).count()
        if management_count == 0:
            messages.error(request, 'Hubo un error, favor contactese con los administradores')
            return redirect('department_activate_list')    
        department_count = Deparment.objects.filter(management_id=management_id).filter(state='Activo').count()
        if department_count > 0:
            messages.error(request, 'No es posible bloquear esta direción ya que tiene departamentos activos')
            return redirect('management_list_active') 
        poll_count = Incident.objects.filter(management_id=management_id).filter(state='Activo').count()
        if poll_count > 0:
            messages.error(request, 'No es posible bloquear esta dirección ya que tiene incidencias activas')
            return redirect('management_list_active')                        
        Management.objects.filter(pk=management_id).update(state='Bloqueado')
        messages.success(request, 'Dirección bloqueada')
        return redirect('management_list_active')
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')  
@login_required
def management_activate(request,management_id):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        management_count = Management.objects.filter(pk=management_id).count()
        if management_count == 0:
            messages.error(request, 'Hubo un error, favor contactese con los administradores')
            return redirect('department_activate_list')    
        Management.objects.filter(pk=management_id).update(state='Activo')
        messages.success(request, 'Dirección activada')
        return redirect('management_list_block')
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')  
@login_required
def management_edit(request,management_id): 
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        management_count = Management.objects.filter(pk=management_id).count()
        if management_count <= 0:
            messages.error(request, 'Hubo un error al editar una dirección')
            return redirect('check_group_main') 
        management_data = Management.objects.get(pk=management_id)
        management_user_data = User.objects.get(pk=management_data.user_id)
        template_name = 'management/management_edit.html'    
        return render(request,template_name,{'username': request.user.username,'management_data':management_data,'management_user_data':management_user_data})
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')  
@login_required
def management_edit_save(request): 
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        if request.method == 'POST':
            management_id = request.POST.get('management_id')
            management_name = request.POST.get('management_name')
            management_in_charge = request.POST.get('management_in_charge')
            management_in_charge_mail = request.POST.get('management_in_charge_mail')
            if management_name == '' or management_in_charge == '' or management_in_charge_mail == '' or management_id == '':
                messages.warning(request, 'Debe ingresar toda la información')
                return redirect('management_list_active')   
            management_data_count = Management.objects.filter(pk=management_id).count()
            if management_data_count <= 0:
                messages.error(request, 'Hubo un error, favor contactese con los administradores')
                return redirect('check_group_main')                  
            Management.objects.filter(pk=management_id).update(management_name = management_name.title())
            Management.objects.filter(pk=management_id).update(management_in_charge = management_in_charge.title())
            Management.objects.filter(pk=management_id).update(management_in_charge_mail = management_in_charge_mail.upper())
            messages.success(request, 'Dirección editada')
            return redirect('management_list_active')  
        else:
            messages.error(request, 'Hubo un error, favor contactese con los administradores')
            return redirect('check_group_main')       
    except:
        messages.error(request, 'Hubo un error, favor contactese con los administradores')
        return redirect('check_group_main')   
    
@login_required
#Reporte de excel activas
def report_list_actives(request):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        list_active = Management.objects.filter(state = 'Activo').order_by('management_name')
        list_desactive = Management.objects.filter(state = 'Bloqueado').order_by('management_name')
        print(list_active)
        response = HttpResponse(content_type = 'application/ms-excel')
        response['Content-Disposition'] = 'attachment; filename="ReporteDireccionesActivas.xls"'
        wb = xlwt.Workbook(encoding='utf-8')

        ws = wb.add_sheet('Activas')
        row_num = 0
        columns = ['Nombre', 'Encargado', 'Correo']
        font_style = xlwt.XFStyle()
        font_style.font.bold = True

        for col_num in range(len(columns)):
            ws.write(row_num, col_num, columns[col_num], font_style)

        font_style = xlwt.XFStyle()

        ws.col(0).width = 256 * 40
        ws.col(1).width = 256 * 30
        ws.col(2).width = 256 * 30 

        for management in list_active:
            row_num += 1
            ws.write(row_num, 0, management.management_name, font_style)
            ws.write(row_num, 1, management.management_in_charge, font_style)
            ws.write(row_num, 2, management.management_in_charge_mail, font_style)

        wb.save(response)
        return response
    
    except Exception as e:
        print(f"Error generating report: {str(e)}")
        messages.add_message(request, messages.INFO, f'Error al generar el reporte: {str(e)}')
        return redirect('management_list_actives')
    
@login_required
#Reporte de excel desactivas
def report_list_block(request):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        list_active = Management.objects.filter(state = 'Activo').order_by('management_name')
        list_desactive = Management.objects.filter(state = 'Bloqueado').order_by('management_name')
        print(list_active)
        response = HttpResponse(content_type = 'application/ms-excel')
        response['Content-Disposition'] = 'attachment; filename="ReporteDireccionesDesactivas.xls"'
        wb = xlwt.Workbook(encoding='utf-8')

        ws = wb.add_sheet('Desactivas')
        row_num = 0
        columns = ['Nombre', 'Encargado', 'Correo']
        font_style = xlwt.XFStyle()
        font_style.font.bold = True

        for col_num in range(len(columns)):
            ws.write(row_num, col_num, columns[col_num], font_style)

        font_style = xlwt.XFStyle()

        ws.col(0).width = 256 * 40
        ws.col(1).width = 256 * 30
        ws.col(2).width = 256 * 30 

        for management in list_desactive:
            row_num += 1
            ws.write(row_num, 0, management.management_name, font_style)
            ws.write(row_num, 1, management.management_in_charge, font_style)
            ws.write(row_num, 2, management.management_in_charge_mail, font_style)

        wb.save(response)
        return response
    
    except Exception as e:
        print(f"Error generating report: {str(e)}")
        messages.add_message(request, messages.INFO, f'Error al generar el reporte: {str(e)}')
        return redirect('management_list_block')
    
