import json
import xlwt
from datetime import datetime, timedelta, date
from django.contrib import messages
from django.contrib.auth.models import User, Group
from django.contrib.auth.decorators import login_required
from django.core.paginator import EmptyPage, PageNotAnInteger, Paginator
from django.db.models import Count, Avg, Q
from django.core.files.storage import FileSystemStorage
from django.conf import settings 
from django.http import HttpResponse, HttpResponseBadRequest, HttpResponseNotFound, HttpResponseRedirect, JsonResponse
from django.shortcuts import render,redirect,get_object_or_404
from django.template import RequestContext
from django.urls import reverse, reverse_lazy
from django.views.decorators.csrf import csrf_exempt
from administrator.models import Config
from registration.models import Profile
from incident.models import Incident
from poll.models import Poll, Fields, Request, RequestAnswer, RequestRecord
from brigade.models import Brigade
from core.utils import *

@login_required
def brigade_request_view_delivery(request, request_id):
    session = int(check_profile_brigade(request))
    if session == 0:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        poll_request = Request.objects.get(pk=request_id)
        poll_id = poll_request.poll_id
        poll_request_state = poll_request.request_state
    except Request.DoesNotExist:
        messages.add_message(request, messages.INFO, 'Hubo un error al acceder a la solicitud')
        return redirect('cuadrilla_main')
    
    # Obtener los campos estándar activos
    poll_fields_standard = Fields.objects.filter(poll_id=poll_id, state='Activo', kind_field='standard').order_by('id')
    poll_fields_other = Fields.objects.filter(poll_id=poll_id, state='bloqueado', kind_field='other').order_by('id')
    
    # Verificar que existen campos para el poll_id dado
    if not poll_fields_standard.exists():
        messages.add_message(request, messages.INFO, 'No se encontraron campos para la encuesta proporcionada')
        return redirect('management_main')
    
    # Obtener la encuesta creada
    poll_data = Poll.objects.get(pk=poll_id)
    
    # Obtener las respuestas de las solicitudes que coincidan con los campos rescatados
    request_answers = RequestAnswer.objects.filter(fields__in=poll_fields_standard).filter(request_id=request_id).select_related('fields', 'request', 'user')
    
    # Crear una lista de tuplas (nombre del campo, valor de respuesta)
    field_answer_pairs = []
    images = []
    lat = ''
    lon = ''
    incidence_video = ''
    incidence_audio = ''
    for field in poll_fields_standard:
        answer = request_answers.filter(fields=field).first()
        #field_answer_pairs.append((field.name, answer.request_answer_text if answer else ''))
        field_answer_pairs.append((field.name, answer.request_answer_text if answer else ''))
        if field.name == 'incidence_latitud':
            lat = answer.request_answer_text if answer else ''
        if field.name == 'incidence_longitud':
            lon = answer.request_answer_text if answer else ''
        if field.name == 'incidence_video':
            incidence_video = answer.request_answer_text if answer else ''
        if field.name == 'incidence_audio':
            incidence_audio = answer.request_answer_text if answer else ''

    for field in poll_fields_standard:
        if field.name == 'incidence_image':
            answer = request_answers.filter(fields=field)
            for a in answer:
                incidence_image = a.request_answer_text if answer else ''
                images.append(incidence_image)

    user_create_incident = poll_request.user.first_name+' '+poll_request.user.last_name
    template_name = 'brigade/brigade_request_view_delivery.html'
    
    context = {
        'request_id': request_id,
        'poll_data': poll_data,
        'field_answer_pairs': field_answer_pairs,
        'poll_fields_other': poll_fields_other,
        'username': request.user.username,
        'lat':lat,
        'lon':lon,
        'incidence_video':incidence_video,
        'images':images,
        'user_create_incident':user_create_incident,
        'incidence_audio':incidence_audio,
        'poll_request_state':poll_request_state
    }
    
    return render(request, template_name, context)


@csrf_exempt
@login_required
def brigade_star_process(request):
    session = int(check_profile_brigade(request))
    if session == 0:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    if request.method == 'POST':
        # Obtener los datos del cuerpo de la solicitud JSON
        data = json.loads(request.body.decode('utf-8'))
        request_id = data.get('request_id')        
        # Obtener el objeto Request utilizando el poll_id
        poll_request = get_object_or_404(Request, pk=request_id)

        # Actualizar el campo request_state a 'Derivada'
        poll_request.request_state = 'Proceso'
        poll_request.request_accept = datetime.now().date()
        poll_request.save()
        
        return JsonResponse({'status': 'success'}, status=200)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=400)

@csrf_exempt
@login_required
def brigade_decline_request(request):
    session = int(check_profile_brigade(request))
    if session == 0:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    if request.method == 'POST':
        # Obtener los datos del cuerpo de la solicitud JSON
        data = json.loads(request.body.decode('utf-8'))
        request_id = data.get('request_id')     
        reason_for_decline = data.get('reason_for_decline')   
        # Obtener el objeto Request utilizando el poll_id
        poll_request = get_object_or_404(Request, pk=request_id)

        # Actualizar el campo request_state a 'Derivada'
        poll_request.request_state = 'Iniciada'
        poll_request.request_accept = None
        poll_request.request_delivery = None
        poll_request.brigade_id = 0
        poll_request.save()
        #Agregamos registro razon cancelación
        request_record_save = RequestRecord(
            user_id = request.user.id,
            request_id = request_id,
            request_record_kind = 'Rechazada',
            request_record_text = reason_for_decline,
            )
        request_record_save.save()        
        return JsonResponse({'status': 'success'}, status=200)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=400)
@login_required
def brigade_list_progress(request,page=None):  
    session = int(check_profile_brigade(request))
    if session == 0:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    #datos cuadrilla
    try:
        brigade_data = Brigade.objects.get(user_id=request.user.id)
        profiles = Profile.objects.get(user_id = request.user.id)
    except Brigade.DoesNotExist:
        messages.add_message(request, messages.INFO, 'Hubo un error')
        return redirect('login')
    #cuenta solicitudes derivadas
    request_delivery_count = Request.objects.filter(request_state='Derivada').filter(brigade_id=brigade_data.id).count()
    request_in_progress_count = Request.objects.filter(request_state='Proceso').filter(brigade_id=brigade_data.id).count()
    request_end_count = Request.objects.filter(request_state='Finalizada').filter(brigade_id=brigade_data.id).count()    
    if page == None:
        page = request.GET.get('page')
    else:
        page = page
    if request.GET.get('page') == None:
        page = page
    else:
        page = request.GET.get('page')
    page = request.GET.get('page')
    incident_list = Request.objects.filter(request_state='Proceso').filter(brigade_id=brigade_data.id)
    paginator = Paginator(incident_list, QUANTITY_LIST) 
    request_activate_list = paginator.get_page(page)
    template_name = 'brigade/brigade_list_progress.html'    
    return render(request,template_name,{'profiles':profiles,'request_activate_list':request_activate_list,'incident_list':incident_list, 'username': request.user.username,'request_delivery_count':request_delivery_count,'request_in_progress_count':request_in_progress_count,'request_end_count':request_end_count})

@login_required
def brigade_poll_view_progress(request,request_id):
    session = int(check_profile_brigade(request))
    if session == 0:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')

    try:
        poll_request = Request.objects.get(pk=request_id)
        poll_id = poll_request.poll_id
        poll_request_state = poll_request.request_state
    except Request.DoesNotExist:
        messages.add_message(request, messages.INFO, 'Hubo un error al acceder a la solicitud')
        return redirect('cuadrilla_main')
    
    # Obtener los campos estándar activos
    poll_fields_standard = Fields.objects.filter(poll_id=poll_id, state='Activo', kind_field='standard').order_by('id')
    poll_fields_other = Fields.objects.filter(poll_id=poll_id, state='bloqueado', kind_field='other').order_by('id')
    
    # Verificar que existen campos para el poll_id dado
    if not poll_fields_standard.exists():
        messages.add_message(request, messages.INFO, 'No se encontraron campos para la encuesta proporcionada')
        return redirect('management_main')
    
    # Obtener la encuesta creada
    poll_data = Poll.objects.get(pk=poll_id)
    
    # Obtener las respuestas de las solicitudes que coincidan con los campos rescatados
    request_answers = RequestAnswer.objects.filter(fields__in=poll_fields_standard).filter(request_id=request_id).select_related('fields', 'request', 'user')
    
    # Crear una lista de tuplas (nombre del campo, valor de respuesta)
    field_answer_pairs = []
    images = []
    lat = ''
    lon = ''
    incidence_video = ''
    incidence_audio = ''
    for field in poll_fields_standard:
        answer = request_answers.filter(fields=field).first()
        #field_answer_pairs.append((field.name, answer.request_answer_text if answer else ''))
        field_answer_pairs.append((field.name, answer.request_answer_text if answer else ''))
        if field.name == 'incidence_latitud':
            lat = answer.request_answer_text if answer else ''
        if field.name == 'incidence_longitud':
            lon = answer.request_answer_text if answer else ''
        if field.name == 'incidence_video':
            incidence_video = answer.request_answer_text if answer else ''
        if field.name == 'incidence_audio':
            incidence_audio = answer.request_answer_text if answer else ''

    for field in poll_fields_standard:
        if field.name == 'incidence_image':
            answer = request_answers.filter(fields=field)
            for a in answer:
                incidence_image = a.request_answer_text if answer else ''
                images.append(incidence_image)

    user_create_incident = poll_request.user.first_name+' '+poll_request.user.last_name
    template_name = 'brigade/brigade_poll_view_progress.html'
    
    context = {
        'request_id': request_id,
        'poll_data': poll_data,
        'field_answer_pairs': field_answer_pairs,
        'poll_fields_other': poll_fields_other,
        'username': request.user.username,
        'lat':lat,
        'lon':lon,
        'incidence_video':incidence_video,
        'images':images,
        'user_create_incident':user_create_incident,
        'incidence_audio':incidence_audio,
        'poll_request_state':poll_request_state
        }
    return render(request, template_name, context)

@login_required
def brigade_poll_view_finish(request,request_id):
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        profile = None
    if profiles.group_id != 5:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')    
    session = int(check_profile_brigade(request))
    if session == 0:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    try:
        poll_request = Request.objects.get(pk=request_id)
        poll_id = poll_request.poll_id
        poll_request_state = poll_request.request_state
    except Request.DoesNotExist:
        messages.add_message(request, messages.INFO, 'Hubo un error al acceder a la solicitud')
        return redirect('cuadrilla_main')
    # Obtener los campos estándar activos
    poll_fields_standard = Fields.objects.filter(poll_id=poll_id, state='Activo', kind_field='standard').order_by('id')
    poll_fields_other = Fields.objects.filter(poll_id=poll_id, state='bloqueado', kind_field='other').order_by('id')
    # Verificar que existen campos para el poll_id dado
    if not poll_fields_standard.exists():
        messages.add_message(request, messages.INFO, 'No se encontraron campos para la encuesta proporcionada')
        return redirect('management_main')
    # Obtener la encuesta creada
    poll_data = Poll.objects.get(pk=poll_id)
    # Obtener las respuestas de las solicitudes que coincidan con los campos rescatados
    request_answers = RequestAnswer.objects.filter(fields__in=poll_fields_standard).filter(request_id=request_id).select_related('fields', 'request', 'user')
    # Crear una lista de tuplas (nombre del campo, valor de respuesta)
    field_answer_pairs = []
    images = []
    lat = ''
    lon = ''
    incidence_video = ''
    incidence_audio = ''
    for field in poll_fields_standard:
        answer = request_answers.filter(fields=field).first()
        #field_answer_pairs.append((field.name, answer.request_answer_text if answer else ''))
        field_answer_pairs.append((field.name, answer.request_answer_text if answer else ''))
        if field.name == 'incidence_latitud':
            lat = answer.request_answer_text if answer else ''
        if field.name == 'incidence_longitud':
            lon = answer.request_answer_text if answer else ''
        if field.name == 'incidence_video':
            incidence_video = answer.request_answer_text if answer else ''
        if field.name == 'incidence_audio':
            incidence_audio = answer.request_answer_text if answer else ''

    for field in poll_fields_standard:
        if field.name == 'incidence_image':
            answer = request_answers.filter(fields=field)
            for a in answer:
                incidence_image = a.request_answer_text if answer else ''
                images.append(incidence_image)

    user_create_incident = poll_request.user.first_name+' '+poll_request.user.last_name
    fields_record= RequestRecord.objects.filter(request_id=request_id)
    template_name = 'brigade/brigade_poll_view_finish.html'
    
    context = {
        'request_id': request_id,
        'poll_data': poll_data,
        'field_answer_pairs': field_answer_pairs,
        'poll_fields_other': poll_fields_other,
        'username': request.user.username,
        'lat':lat,
        'lon':lon,
        'incidence_video':incidence_video,
        'images':images,
        'user_create_incident':user_create_incident,
        'incidence_audio':incidence_audio,
        'fields_record':fields_record,
        'poll_request_state':poll_request_state
        }
    return render(request, template_name, context)
#revisar

@login_required
def brigade_list_finish(request,page=None):  
    session = int(check_profile_brigade(request))
    if session == 0:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    #datos cuadrilla
    try:
        brigade_data = Brigade.objects.get(user_id=request.user.id)
        profiles = Profile.objects.get(user_id = request.user.id)
    except Brigade.DoesNotExist:
        messages.add_message(request, messages.INFO, 'Hubo un error')
        return redirect('login')
    #cuenta solicitudes derivadas
    request_delivery_count = Request.objects.filter(request_state='Derivada').filter(brigade_id=brigade_data.id).count()
    request_in_progress_count = Request.objects.filter(request_state='Proceso').filter(brigade_id=brigade_data.id).count()
    request_end_count = Request.objects.filter(request_state='Finalizada').filter(brigade_id=brigade_data.id).count()    
    if page == None:
        page = request.GET.get('page')
    else:
        page = page
    if request.GET.get('page') == None:
        page = page
    else:
        page = request.GET.get('page')    
    page = request.GET.get('page')
    incident_list = Request.objects.filter(request_state='Finalizada').filter(brigade_id=brigade_data.id)
    paginator = Paginator(incident_list, QUANTITY_LIST) 
    request_activate_list = paginator.get_page(page)
    template_name = 'brigade/brigade_list_finish.html'    
    return render(request,template_name,{'profiles':profiles,'request_activate_list':request_activate_list,'incident_list':incident_list, 'username': request.user.username,'request_delivery_count':request_delivery_count,'request_in_progress_count':request_in_progress_count,'request_end_count':request_end_count})






@login_required
def brigade_cancel(request,request_id):
    profiles = Profile.objects.get(user_id = request.user.id)
    if profiles.group_id != 5:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    Request.objects.filter(pk=request_id).update(request_state='Cancelada')
    messages.success(request, 'Solicitud cancelada')
    return redirect('cuadrilla_main')

@login_required
def brigade_view_profile(request):
    profiles = Profile.objects.get(user_id=request.user.id)
    if profiles.group_id != 5:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a un área para la que no tiene permisos')
        return redirect('check_group_main')
    user = request.user
    profiles = Profile.objects.get(user_id = request.user.id)

    if request.method == 'POST':
        # Si se envía un formulario de edición, actualiza los datos
        user.first_name = request.POST.get('first_name')
        user.last_name = request.POST.get('last_name')
        user.email = request.POST.get('email')
        user.save()
        messages.success(request, 'Perfil actualizado exitosamente.')

    # Obtiene los datos actualizados del usuario
    user.refresh_from_db()

    context = {
        'user_data': user,
        'first_name': user.first_name,
        'last_name': user.last_name,
        'email': user.email,
        'cargo': profiles.group.name, 
    }
    
    template_name = 'brigade/brigade_view_profile.html'
    return render(request, template_name, context )

@login_required
def brigade_alert(request):
    if request.method == 'POST':
        fs= FileSystemStorage()
        request_id=request.POST.get('request_id')
        Request.objects.filter(pk=request_id).update(request_state='Finalizada')
        Request.objects.filter(pk=request_id).update(request_finish=datetime.now().date())
        # Aquí procesas los archivos recibidos
        files = request.FILES.getlist('incidentImage')
        description=request.POST.get('incidentDescription')
        
        if description:
            request_answ_record_save=RequestRecord(
                request_record_kind= 'Descripcion',
                request_record_text= description,
                request_id=request_id,
                user_id=request.user.id,
            )
            request_answ_record_save.save()
        if files:
            for file in files:
                file_path=fs.save(file.name,file)
                uploaded_file_path=fs.url(file_path)
                request_answ_record_save=RequestRecord(
                    request_record_kind= 'Imagenes',
                    request_record_text= uploaded_file_path,
                    request_id=request_id,
                    user_id=request.user.id,
                )
                request_answ_record_save.save()
        messages.success(request, 'Información Guardada Exitosamente')
        return JsonResponse({'status': 'success'}, status=200)
    return JsonResponse({'status': 'error', 'message': 'Método no permitido'}, status=405)

@login_required
#Reporte de excel derivadas
def report_list_derived(request):
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
        if profiles.group_id != 5:
            messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
            return redirect('check_group_main')
        
        list_array = Request.objects.filter(request_state = 'Derivada').order_by('request_name')
        response = HttpResponse(content_type = 'application/ms-excel')
        response['Content-Disposition'] = 'attachment; filename="ReporteEncuestasDerivadas.xls"'
        wb = xlwt.Workbook(encoding='utf-8')
        ws = wb.add_sheet('Encuestas')
        row_num = 0
        columns = ['Nombre', 'Solicitada el', 'Derivada el', 'Tipo solicitud']
        font_style = xlwt.XFStyle()
        font_style.font.bold = True

        for col_num in range(len(columns)):
            ws.write(row_num, col_num, columns[col_num], font_style)
        
        font_style = xlwt.XFStyle()
        date_format = xlwt.XFStyle()
        date_format.num_format_str = 'dd/MM/yyyy'

        ws.col(0).width = 256 * 15
        ws.col(1).width = 256 * 15
        ws.col(2).width = 256 * 15
        ws.col(3).width = 256 * 30

        for request in list_array:
            row_num += 1
            ws.write(row_num, 0, request.request_name, font_style)
            ws.write(row_num, 1, request.request_date, date_format)
            ws.write(row_num, 2, request.request_delivery, date_format)
            ws.write(row_num, 3, request.poll.incident.name, font_style)

        wb.save(response)
        return response
    
    except Exception as e:
        messages.add_message(request, messages.INFO, f'Error al generar el reporte: {str(e)}')
        return redirect('cuadrilla_main')
    

@login_required
#Reporte de excel en proceso
def report_list_progress(request):
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
        if profiles.group_id != 5:
            messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
            return redirect('check_group_main')
        
        list_array = Request.objects.filter(request_state = 'Proceso').order_by('request_name')
        response = HttpResponse(content_type = 'application/ms-excel')
        response['Content-Disposition'] = 'attachment; filename="ReporteEncuestasEnProceso.xls"'
        wb = xlwt.Workbook(encoding='utf-8')
        ws = wb.add_sheet('Encuestas')
        row_num = 0
        columns = ['Nombre', 'Solicitada el', 'Derivada el', 'Iniciada el', 'Tipo solicitud']
        font_style = xlwt.XFStyle()
        font_style.font.bold = True

        for col_num in range(len(columns)):
            ws.write(row_num, col_num, columns[col_num], font_style)
        
        font_style = xlwt.XFStyle()
        date_format = xlwt.XFStyle()
        date_format.num_format_str = 'dd/MM/yyyy'

        ws.col(0).width = 256 * 15
        ws.col(1).width = 256 * 15
        ws.col(2).width = 256 * 15
        ws.col(3).width = 256 * 15
        ws.col(4).width = 256 * 30

        for request in list_array:
            row_num += 1
            ws.write(row_num, 0, request.request_name, font_style)
            ws.write(row_num, 1, request.request_date, date_format)
            ws.write(row_num, 2, request.request_delivery, date_format)
            ws.write(row_num, 3, request.request_accept, date_format)
            ws.write(row_num, 4, request.poll.incident.name, font_style)

        wb.save(response)
        return response
    
    except Exception as e:
        messages.add_message(request, messages.INFO, f'Error al generar el reporte: {str(e)}')
        return redirect('brigade_list_progress')
    

@login_required
#Reporte de excel finalizado
def report_list_finish(request):
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
        if profiles.group_id != 5:
            messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
            return redirect('check_group_main')
        
        list_array = Request.objects.filter(request_state = 'Finalizada').order_by('request_name')
        response = HttpResponse(content_type = 'application/ms-excel')
        response['Content-Disposition'] = 'attachment; filename="ReporteEncuestasFinalizadas.xls"'
        wb = xlwt.Workbook(encoding='utf-8')
        ws = wb.add_sheet('Encuestas')
        row_num = 0
        columns = ['Nombre', 'Solicitada el', 'Derivada el', 'Iniciada el', 'Finalizada el', 'Tipo solicitud']
        font_style = xlwt.XFStyle()
        font_style.font.bold = True

        for col_num in range(len(columns)):
            ws.write(row_num, col_num, columns[col_num], font_style)
        
        font_style = xlwt.XFStyle()
        date_format = xlwt.XFStyle()
        date_format.num_format_str = 'dd/MM/yyyy'

        ws.col(0).width = 256 * 15
        ws.col(1).width = 256 * 15
        ws.col(2).width = 256 * 15
        ws.col(3).width = 256 * 15
        ws.col(4).width = 256 * 15
        ws.col(5).width = 256 * 30

        for request in list_array:
            row_num += 1
            ws.write(row_num, 0, request.request_name, font_style)
            ws.write(row_num, 1, request.request_date, date_format)
            ws.write(row_num, 2, request.request_delivery, date_format)
            ws.write(row_num, 3, request.request_accept, date_format)
            ws.write(row_num, 4, request.request_finish, date_format)
            ws.write(row_num, 5, request.poll.incident.name, font_style)

        wb.save(response)
        return response
    
    except Exception as e:
        messages.add_message(request, messages.INFO, f'Error al generar el reporte: {str(e)}')
        return redirect('brigade_list_finish')

