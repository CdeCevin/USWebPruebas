from django.shortcuts import render,redirect, get_object_or_404
from registration.models import Profile
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from poll.models import Poll, Fields, Request, RequestAnswer
from incident.models import Incident
from django.core.paginator import Paginator
from django.contrib.auth.models import User
from django.db.models import Q
from django.core.files.storage import FileSystemStorage
from core.utils import *
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from django.urls import reverse
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.hashers import check_password
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.utils.http import urlsafe_base64_encode
from django.utils.encoding import force_bytes
from django.core.mail import send_mail
import re
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.utils.http import urlsafe_base64_encode
from django.utils.encoding import force_bytes
from django.core.mail import send_mail
from rest_framework.permissions import AllowAny
from datetime import datetime
import pandas as pd
import xlwt
from django.http import HttpResponse, HttpResponseBadRequest, HttpResponseNotFound, HttpResponseRedirect
from django.http import JsonResponse
from django.views.decorators.http import require_GET
from manuals.models import Manuals

@login_required
def territorial_main(request):  
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
        session = int(check_profile_territorial(request))
        if session == 2:
            messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
            return redirect('logout')        
    except Profile.DoesNotExist:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    if profiles.group_id != 2:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    template_name = 'territorial/territorial_main.html'  
    return render(request,template_name,{'profiles':profiles})

@login_required
def report_list_polls_territorial_active(request):
    try:
        profiles = Profile.objects.get(user_id=request.user.id)
        # Verificar que el perfil pertenezca solo a los grupos con ID 1 o 2
        if profiles.group_id not in [1, 2]:
            messages.add_message(request, messages.INFO, 'Intenta ingresar a un área para la que no tiene permisos')
            return redirect('check_group_main')

        # Obtener encuestas
        poll_array = Poll.objects.filter(state__iexact='Activo').order_by('name')
        response = HttpResponse(content_type='application/ms-excel')
        response['Content-Disposition'] = 'attachment; filename="Reporte_encuestas_activas_terrirorial.xls"'

        wb = xlwt.Workbook(encoding='utf-8')
        ws = wb.add_sheet('Encuestas')

        row_num = 0
        columns = [
            'Nombre de Encuesta', 'Fecha Creación Encuesta',
            'Nombre Incidencia', 'Fecha Creación Incidencia'
        ]
        font_style = xlwt.XFStyle()
        font_style.font.bold = True

        # Escribir encabezados
        for col_num, column_title in enumerate(columns):
            ws.write(row_num, col_num, column_title, font_style)

        font_style = xlwt.XFStyle()

        # Escribir datos de las encuestas y sus incidentes relacionados
        for poll in poll_array:
            row_num += 1
            ws.write(row_num, 0, poll.name, font_style)  # Nombre de la encuesta
            #ws.write(row_num, 1, poll.state, font_style)  # Estado de la encuesta
            #ws.write(row_num, 2, poll.incident_id, font_style)  # ID del incidente
            ws.write(row_num, 1, poll.created.strftime('%Y-%m-%d'), font_style)  # Fecha de creación de la encuesta

            # Verificar si la encuesta tiene una incidencia asociada y escribir sus datos
            if poll.incident:
                ws.write(row_num, 2, poll.incident.name, font_style)  # Nombre del incidente
                #ws.write(row_num, 5, poll.incident.state, font_style)  # Estado del incidente
                ws.write(row_num, 3, poll.incident.created.strftime('%Y-%m-%d'), font_style)  # Fecha de creación del incidente
            else:
                ws.write(row_num, 2, 'N/A', font_style)  # Nombre del incidente
                #ws.write(row_num, 5, 'N/A', font_style)  # Estado del incidente
                ws.write(row_num, 3, 'N/A', font_style)  # Fecha de creación del incidente

        wb.save(response)
        
        # En lugar de redirigir, retornamos el archivo como respuesta
        return response

    except Exception as e:
        messages.add_message(request, messages.INFO, f'Error al generar el reporte: {str(e)}')
        return redirect('territorial_list')

@login_required
def report_list_polls_territorial_desactive(request):
    try:
        profiles = Profile.objects.get(user_id=request.user.id)
        # Verificar que el perfil pertenezca solo a los grupos con ID 1 o 2
        if profiles.group_id not in [1, 2]:
            messages.add_message(request, messages.INFO, 'Intenta ingresar a un área para la que no tiene permisos')
            return redirect('check_group_main')

        # Obtener encuestas
        poll_array = Poll.objects.filter(state__iexact='Bloqueado').order_by('name')
        response = HttpResponse(content_type='application/ms-excel')
        response['Content-Disposition'] = 'attachment; filename="Reporte_encuestas_desactivas_terrirorial.xls"'

        wb = xlwt.Workbook(encoding='utf-8')
        ws = wb.add_sheet('Encuestas')

        row_num = 0
        columns = [
            'Nombre de Encuesta', 'Fecha Creación Encuesta',
            'Nombre Incidencia', 'Fecha Creación Incidencia'
        ]
        font_style = xlwt.XFStyle()
        font_style.font.bold = True

        # Escribir encabezados
        for col_num, column_title in enumerate(columns):
            ws.write(row_num, col_num, column_title, font_style)

        font_style = xlwt.XFStyle()

        # Escribir datos de las encuestas y sus incidentes relacionados
        for poll in poll_array:
            row_num += 1
            ws.write(row_num, 0, poll.name, font_style)  # Nombre de la encuesta
            #ws.write(row_num, 1, poll.state, font_style)  # Estado de la encuesta
            #ws.write(row_num, 2, poll.incident_id, font_style)  # ID del incidente
            ws.write(row_num, 1, poll.created.strftime('%Y-%m-%d'), font_style)  # Fecha de creación de la encuesta

            # Verificar si la encuesta tiene una incidencia asociada y escribir sus datos
            if poll.incident:
                ws.write(row_num, 2, poll.incident.name, font_style)  # Nombre del incidente
                #ws.write(row_num, 5, poll.incident.state, font_style)  # Estado del incidente
                ws.write(row_num, 3, poll.incident.created.strftime('%Y-%m-%d'), font_style)  # Fecha de creación del incidente
            else:
                ws.write(row_num, 2, 'N/A', font_style)  # Nombre del incidente
                #ws.write(row_num, 5, 'N/A', font_style)  # Estado del incidente
                ws.write(row_num, 3, 'N/A', font_style)  # Fecha de creación del incidente

        wb.save(response)
        
        # En lugar de redirigir, retornamos el archivo como respuesta
        return response

    except Exception as e:
        messages.add_message(request, messages.INFO, f'Error al generar el reporte: {str(e)}')
        return redirect('territorial_list_finished')

@login_required
def territorial_list(request,page=None):  
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        profile = None
    if profiles.group_id != 2:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    
    page = request.GET.get('page') if page is None else page if request.GET.get('page') is None else request.GET.get('page')  
    
    #poll_activate = Poll.objects.filter(Q(state='Rechazado') | Q(state='creacion')).order_by('name')
    poll_activate = Poll.objects.filter(state='Activo').order_by('name')
    page = request.GET.get('page')
    paginator = Paginator(poll_activate, 20) 
    poll_activate_list = paginator.get_page(page)
    incident_list = Incident.objects.filter(Q(state='Rechazado') | Q(state='creacion')).values_list('name', flat=True).distinct()
    template_name = 'territorial/territorial_list.html'  
    return render(request,template_name,{'profiles':profiles,'poll_activate_list':poll_activate_list,'incident_list':incident_list, 'username': request.user.username})

@login_required
def territorial_poll_view(request,poll_id):
    profiles = Profile.objects.get(user_id = request.user.id)
    if profiles.group_id != 2:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')    
    #valido que la encuesta existe y se encuentre en estado creacion
    pool_count = Poll.objects.filter(pk=poll_id).count()
    if pool_count == 0:
        messages.error(request, 'Hubo un error al acceder a la encuesta')
        return redirect('territorial_main')    
    #obtengo la encuesta creada
    poll_data = Poll.objects.get(pk=poll_id)
    poll_fields_standard_array = []
    poll_fields_standard = Fields.objects.filter(poll_id=poll_id).filter(state='Activo').filter(kind_field='standard')
    for p in poll_fields_standard:
        poll_fields_standard_array.append(p.name)    
    poll_fields_other = Fields.objects.filter(poll_id=poll_id).filter(state='Activo').filter(kind_field='other').order_by('name')
    template_name = 'territorial/territorial_poll_view.html'    
    return render(request,template_name,{'poll_data':poll_data,'poll_fields_standard_array':poll_fields_standard_array,'poll_fields_other':poll_fields_other, 'username': request.user.username}) 
@login_required
def territorial_request_poll(request, poll_id):
    #Validaciones de usuario
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    if profiles.group_id != 2:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    pool_count = Poll.objects.filter(pk=poll_id).count()
    if pool_count == 0:
        messages.error(request, 'Hubo un error, la encuesta no se encuentra. Contactar al Administrador')
        return redirect('territorial_main')
    
    #Obtencion de campos para la encuesta
    incidents = Incident.objects.filter(state='Activo').order_by('name')
    poll_data = Poll.objects.get(pk=poll_id)
    poll_fields_standard_array = []
    poll_fields_standard = Fields.objects.filter(poll_id=poll_id).filter(state='Activo').filter(kind_field='standard')
    for p in poll_fields_standard:
        poll_fields_standard_array.append(p.name)
    poll_fields_other = Fields.objects.filter(poll_id=poll_id).filter(state='Activo').filter(kind_field='other').order_by('name')
    template_name = 'territorial/territorial_request_poll.html'
    
    return render(request, template_name, {'incidents': incidents, 'poll_data': poll_data,'poll_fields_standard_array': poll_fields_standard_array,'poll_fields_other':poll_fields_other, 'username': request.user.username})

@login_required
def territorial_request_save(request):
    #Validaciones de usuario
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    if profiles.group_id != 2:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    
    #Obtencion de ID para asociar la request
    if request.method == 'POST':
            poll_id = request.POST.get('poll_id')
    poll_data = Poll.objects.get(pk=poll_id)

    #Validar Encuesta
    pool_count = Poll.objects.filter(pk=poll_id).count()
    if pool_count == 0:
        messages.error(request, 'Hubo un error, la encuesta no se encuentra. Contactar al Administrador')
        return redirect('territorial_main')

    #Crear la request
    request_save=Request(
        user_id= request.user.id,
        poll_id = poll_id,
        deparment_id = poll_data.incident.deparment.id,
        request_name ='Rquest1',
        request_date ='2024-03-29',
    )
    request_save.save()

    #Rellenar la encuesta con los datos ingresados por el territorial
    fields_data = Fields.objects.filter(poll_id=poll_data.id).filter(state='Activo').order_by('id')
    images = request.FILES.getlist('incidence_image')
    video = request.FILES.getlist('incidence_video')
    audio = request.FILES.getlist('incidence_audio')
    fs= FileSystemStorage()
    for r in fields_data:
        if r.name=='incidence_image' or r.name=='incidence_video' or r.name=='incidence_audio':
            if images != '':
                if r.name=='incidence_image':
                    for i in images:
                        file_path=fs.save(i.name,i)
                        uploaded_file_path=fs.url(file_path)
                        request_answ_save=RequestAnswer(
                            request_answer_text= uploaded_file_path,
                            fields_id=r.id,
                            request_id=request_save.id,
                            user_id=request.user.id,
                        )
                        request_answ_save.save()
            elif video != '':    
                if r.name=='incidence_video':
                    for v in video:
                        file_path=fs.save(v.name,v)
                        uploaded_file_path=fs.url(file_path)
                        request_answ_save=RequestAnswer(
                            request_answer_text= uploaded_file_path,
                            fields_id=r.id,
                            request_id=request_save.id,
                            user_id=request.user.id,
                        )
                        request_answ_save.save()
            elif audio != '':
                if r.name=='incidence_audio':
                    for a in audio:
                        file_path=fs.save(a.name,v)
                        uploaded_file_path=fs.url(file_path)
                        request_answ_save=RequestAnswer(
                            request_answer_text= uploaded_file_path,
                            fields_id=r.id,
                            request_id=request_save.id,
                            user_id=request.user.id,
                        )
                        request_answ_save.save()
        else:
            request_answ_save=RequestAnswer(
            request_answer_text= request.POST.get(r.name),
            fields_id=r.id,
            request_id=request_save.id,
            user_id=request.user.id,
            )
            request_answ_save.save()
    messages.success(request, 'Encuesta creada')
    return redirect('territorial_list')  

#revisar
#Revisar ya que es codigo para procesar y visualizar templates
@login_required
def territorial_list_inprogress(request,page=None):  
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        profile = None
    if profiles.group_id != 2:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    
    if page == None:
        page = request.GET.get('page')
    else:
        page = page
    if request.GET.get('page') == None:
        page = page
    else:
        page = request.GET.get('page')    
    poll_activate = Poll.objects.filter(Q(state='Activo') | Q(state='Proceso')).order_by('name')
    page = request.GET.get('page')
    paginator = Paginator(poll_activate, 20) 
    poll_activate_list = paginator.get_page(page)
    incident_list = Incident.objects.filter(Q(state='Activo') | Q(state='Proceso')).values_list('name', flat=True).distinct()
    template_name = 'territorial/territorial_list_inprogress.html'    
    return render(request,template_name,{'profiles':profiles,'poll_activate_list':poll_activate_list,'incident_list':incident_list, 'username': request.user.username})


@login_required
def territorial_list_finished(request,page=None):  
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        profile = None
    if profiles.group_id != 2:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    
    if page == None:
        page = request.GET.get('page')
    else:
        page = page
    if request.GET.get('page') == None:
        page = page
    else:
        page = request.GET.get('page')    
    poll_activate = Poll.objects.filter(Q(state='Finalizado') | Q(state='Bloqueado')).order_by('name')
    page = request.GET.get('page')
    paginator = Paginator(poll_activate, 20) 
    poll_activate_list = paginator.get_page(page)
    incident_list = Incident.objects.filter(Q(state='Finalizado') | Q(state='Bloqueado')).values_list('name', flat=True).distinct()
    template_name = 'territorial/territorial_list_finished.html'    
    return render(request,template_name,{'profiles':profiles,'poll_activate_list':poll_activate_list,'incident_list':incident_list, 'username': request.user.username})

@login_required
def ver_perfil(request):
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    if profiles.group_id != 2:
        messages.warning(request, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    user = request.user
    user = request.user

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
    template_name = 'territorial/ver_perfil.html'
    return render(request, template_name, context)

@login_required
@api_view(['GET'])
def territorial_list_inprogress_ep(request, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    
    if request.method=='GET':
        request_poll = Request.objects.filter(Q(request_state='Proceso')).order_by('request_name')
        poll_json = []

        # Se filtran los detalles por el ID de la request
        for i in request_poll:
            request_data = RequestAnswer.objects.filter(request_id=i.id)

            # Se crea una lista para almacenar los detalles de la request
            details = []
            for j in request_data:
                details.append(j.request_answer_text)

            if i.brigade_id == 0:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':'Cuadrilla sin asignar',
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
            else:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':i.brigade_id,
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
        return Response({'Listado':poll_json})
    else:
        return Response({'Msj':"Error método no soportado"})

@login_required
@api_view(['GET'])
def territorial_list_open_ep(request, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    
    if request.method=='GET':
        request_poll = Request.objects.filter(Q(request_state='Abierta')).order_by('request_name')
        poll_json = []

        # Se filtran los detalles por el ID de la request
        for i in request_poll:
            request_data = RequestAnswer.objects.filter(request_id=i.id)

            # Se crea una lista para almacenar los detalles de la request
            details = []
            for j in request_data:
                details.append(j.request_answer_text)

            if i.brigade_id == 0:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':'Cuadrilla sin asignar',
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
            else:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':i.brigade_id,
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
        return Response({'Listado':poll_json})
    else:
        return Response({'Msj':"Error método no soportado"})

@login_required
@api_view(['GET'])
def territorial_poll_view_ep(request, poll_id, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})

    if request.method == 'GET':
        try:
            poll_data = Poll.objects.get(pk=poll_id)
            poll_fields_standard = Fields.objects.filter(poll_id=poll_id, state='Activo', kind_field='standard')
            poll_fields_other = Fields.objects.filter(poll_id=poll_id, state='Activo', kind_field='other').order_by('name')
            
            poll_json = {
                'ID': poll_data.id,
                'Título': poll_data.name,
                'Tipo Incidencia': poll_data.incident.name,
                'poll_fields_standard': [field.placeholder for field in poll_fields_standard],
                'poll_fields_other': [field.placeholder for field in poll_fields_other],
                'username':request.user.username
            }
            
            return Response({'poll_data': poll_json})
        except Poll.DoesNotExist:
            return Response({'error': 'La encuesta no existe'})
    else:
        return Response({'Msj':"Error método no soportado"})

@login_required
@api_view(['GET'])
def territorial_list_sent_ep(request, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    
    if request.method=='GET':
        request_poll = Request.objects.filter(Q(request_state='Derivada')).order_by('request_name')
        poll_json = []

        # Se filtran los detalles por el ID de la request
        for i in request_poll:
            request_data = RequestAnswer.objects.filter(request_id=i.id)

            # Se crea una lista para almacenar los detalles de la request
            details = []
            for j in request_data:
                details.append(j.request_answer_text)

            if i.brigade_id == 0:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':'Cuadrilla sin asignar',
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
            else:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':i.brigade_id,
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
        return Response({'Listado':poll_json})
    else:
        return Response({'Msj':"Error método no soportado"})

@login_required
@api_view(['GET'])
def territorial_list_finished_ep(request, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    
    if request.method=='GET':
        request_poll = Request.objects.filter(Q(request_state='Finalizada')).order_by('request_name')
        poll_json = []

        # Se filtran los detalles por el ID de la request
        for i in request_poll:
            request_data = RequestAnswer.objects.filter(request_id=i.id)

            # Se crea una lista para almacenar los detalles de la request
            details = []
            for j in request_data:
                details.append(j.request_answer_text)

            if i.brigade_id == 0:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':'Cuadrilla sin asignar',
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
            else:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':i.brigade_id,
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
        return Response({'Listado':poll_json})
    else:
        return Response({'Msj':"Error método no soportado"})

@login_required
@api_view(['GET'])
def territorial_list_closed_ep(request, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    
    if request.method=='GET':
        request_poll = Request.objects.filter(Q(request_state='Cerrar')).order_by('request_name')
        poll_json = []

        # Se filtran los detalles por el ID de la request
        for i in request_poll:
            request_data = RequestAnswer.objects.filter(request_id=i.id)

            # Se crea una lista para almacenar los detalles de la request
            details = []
            for j in request_data:
                details.append(j.request_answer_text)

            if i.brigade_id == 0:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':'Cuadrilla sin asignar',
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
            else:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':i.brigade_id,
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
        return Response({'Listado':poll_json})
    else:
        return Response({'Msj':"Error método no soportado"})

@login_required
@api_view(['GET'])
def territorial_list_rejected_ep(request, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    
    if request.method=='GET':
        request_poll = Request.objects.filter(Q(request_state='Rechazada')).order_by('request_name')
        poll_json = []

        # Se filtran los detalles por el ID de la request
        for i in request_poll:
            request_data = RequestAnswer.objects.filter(request_id=i.id)

            # Se crea una lista para almacenar los detalles de la request
            details = []
            for j in request_data:
                details.append(j.request_answer_text)

            if i.brigade_id == 0:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':'Cuadrilla sin asignar',
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
            else:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':i.brigade_id,
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
        return Response({'Listado':poll_json})
    else:
        return Response({'Msj':"Error método no soportado"})

@login_required
@api_view(['POST'])
def territorial_edit_password_ep(request, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    
    # Lógica edición de contraseña 
    if request.method=='POST':
        perfil = request.user
        password = request.data['password']
        confirmacion_password = request.data['confirmacion_password']
        letras = re.compile(r'[a-zA-Z]')
        numeros = re.compile(r'[0-9]')
        
        if password == confirmacion_password:
            if check_password(password, perfil.password):
                return Response({'Msj':'La contraseña ingresada es igual a la actual'})
            elif len(password) < 6 or ' ' in password or not password.isascii() or not letras.search(password) or not numeros.search(password):
                return Response({'Msj':'La contraseña ingresada no cumple los requisitos'})
            else:
                #Se actualiza el usuario con la sesión activa
                perfil.set_password(password)
                perfil.save()
                return Response({'Msj':'Contraseña editada con exito'})
        else:
            return Response({'Msj':'Las contraseñas no coinciden'})
    else:
        return Response({'Msj':"Error método no soportado"})

@login_required
@api_view(['GET'])
def territorial_see_profile_ep(request, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})

    # Lógica ver perfil
    if request.method=='GET':
        perfil = request.user
        perfil_json =({
            "Nombre":perfil.first_name,
            "Apellido":perfil.last_name,
            "Correo":perfil.email,
            "Cargo":profiles.group.name})
        return Response({'Perfil':perfil_json})
    else:
        return Response({'Msj':'Error, método no soportado'})


@login_required
@api_view(['POST'])
def territorial_edit_profile_ep(request, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    
    # Lógica edición de perfil 
    if request.method=='POST':
        perfil = request.user
        nombre = request.data.get('nombre', perfil.first_name)
        apellido = request.data.get('apellido', perfil.last_name)
        correo = request.data.get('correo', perfil.email)
        
        # Se valida el formato de correo "nombre@dominio.xx"
        if not re.match('^[(a-zA-Z0-9\_\-\.)]+@[(a-zA-Z0-9\_\-\.)]+\.[(a-z)]{2,4}$', correo):
            return Response({'Msj': 'El formato del correo electrónico no es válido'})
        
        # Se verifica si el correo existe ya en la base de datos para otro usuario
        if correo != perfil.email and User.objects.filter(email=correo).exists():
            return Response({'Msj': 'El correo electrónico ya está en uso por otro usuario'})
        
        #Se actualiza el usuario con la sesión activa
        perfil.first_name = nombre
        perfil.last_name = apellido
        perfil.email = correo

        # Se guarda la información del perfil
        perfil.save()
        
        return Response({'Msj':'Perfil editado con éxito'})
    
    else:
        return Response({'Msj':'Error, método no soportado'})

@login_required
@api_view(['GET'])
def territorial_list_ep(request, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    
    if request.method=='GET':
        poll_activate = Poll.objects.filter(state='Activo').order_by('-id')
        poll_json = []
        for i in poll_activate:
            poll_json.append({
                'ID':i.id,
                'Nombre':i.name,
                'Tipo de incidencia':i.incident.name,
                'Estado':i.state,
                'Fecha creación': i.created.strftime('%Y-%m-%d'),
                'Ver Encuesta': f"http://143.198.118.203:8000/territorial/territorial_poll_view_ep/{i.id}"})
        return Response({'Listado':poll_json})
    else:
        return Response({'Msj':'Error, método no soportado'})

@login_required
@api_view(['POST'])
def territorial_request_save_ep(request, format=None):
    # Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id=request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})

    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    
    
    if request.method == 'POST':
        # Obtencion de ID para asociar la request
        data = request.data
        poll_id = data.get('poll_id')

        if not poll_id:
            return Response({'error': 'Se debe ingresar ID de la encuesta'})
    
        # Validar Encuesta
        try:
            poll_data = Poll.objects.get(pk=poll_id)
        except Poll.DoesNotExist:
            return Response({'error': 'Hubo un error, la encuesta no se encuentra. Contactar al Administrador'})
    
        # Crear la request
        request_save = Request(
            user_id=request.user.id,
            poll_id=poll_id,
            deparment_id = poll_data.incident.deparment.id,
            request_name='Solicitud N° ',
            request_date=datetime.now(),
        )
        request_save.save()
        
        request_id = request_save.id

        Request.objects.filter(pk=request_id).update(request_name=f'Solicitud N° {request_id}')

        # Rellenar la encuesta con los datos ingresados por el territorial
        fields_data = Fields.objects.filter(poll_id=poll_data.id).filter(state='Activo').order_by('id')
        images = request.FILES.getlist('incidence_image')
        videos = request.FILES.getlist('incidence_video')
        audios = request.FILES.getlist('incidence_audio')
        fs = FileSystemStorage()
        rev = []
        for r in fields_data:
            if r.name == 'incidence_image':
                for i in images:
                    file_path = fs.save(i.name, i)
                    uploaded_file_path = fs.url(file_path)
                    request_answ_save = RequestAnswer(
                        request_answer_text=uploaded_file_path,
                        fields_id=r.id,
                        request_id=request_save.id,
                        user_id=request.user.id,
                    )
                    request_answ_save.save()
            elif r.name == 'incidence_video':
                for v in videos:
                    file_path = fs.save(v.name, v)
                    uploaded_file_path = fs.url(file_path)
                    request_answ_save = RequestAnswer(
                        request_answer_text=uploaded_file_path,
                        fields_id=r.id,
                        request_id=request_save.id,
                        user_id=request.user.id,
                    )
                    request_answ_save.save()
            elif r.name == 'incidence_audio':
                for a in audios:
                    file_path = fs.save(a.name, a)
                    uploaded_file_path = fs.url(file_path)
                    request_answ_save = RequestAnswer(
                        request_answer_text=uploaded_file_path,
                        fields_id=r.id,
                        request_id=request_save.id,
                        user_id=request.user.id,
                    )
                    request_answ_save.save()
            else:
                answer_text = request.data.get(r.name)
                if answer_text == None:
                    answer_text = request.data.get(r.label)
                request_answ_save = RequestAnswer(
                    request_answer_text=answer_text,
                    fields_id=r.id,
                    request_id=request_save.id,
                    user_id=request.user.id,
                )
                request_answ_save.save()
        return Response({'Msj': 'Encuesta creada'})
    else:
        return Response({'Msj':'Error, método no soportado'})

@api_view(['POST'])
@permission_classes([AllowAny])
def territorial_login_ep(request):
    if request.method == 'POST':
        username = request.data.get('username')
        password = request.data.get('password')
        # Se verifican las credenciales ingresadas
        user = authenticate(request, username=username, password=password)
        user_data = User.objects.get(username=username)
        profile_data = Profile.objects.get(user_id=user_data.id)
        if profile_data.group_id != 2:
            return Response({'Msj': 'No tiene permitido acceder'})
        # Se logea al usuario si se valida
        if user:
            login(request, user)
            try:
                profile = Profile.objects.get(user=user)
                group_id = profile.group_id
            except Profile.DoesNotExist:
                return Response({'Msj': 'Error al obtener el grupo del usuario'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

            return Response({'Msj': 'Inicio de sesión exitoso', 'group_id': group_id})
        else:
            return Response({'Msj': 'Credenciales no válidas'})
    return Response({'Msj':'Error, método no soportado'})

@api_view(['POST'])
def territorial_logout_ep(request):
    if request.method == 'POST':
        logout(request)
        return Response({'Msj': 'Cierre de sesión exitoso'})
    return Response({'Msj':'Error, método no soportado'})

@login_required
@api_view(['POST','GET'])
def territorial_close_request_ep(request, request_id):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    
    if request.method == 'GET':
        try:
            request_poll = Request.objects.get(pk=request_id)
            request_data = RequestAnswer.objects.filter(request_id=request_id)

            details = []
            for j in request_data:
                details.append(j.request_answer_text)

            if request_poll.brigade_id == 0:
                request_json = {
                    'ID': request_poll.id,
                    'Nombre': request_poll.request_name,
                    'Estado': request_poll.request_state,
                    'Cuadrilla': 'Cuadrilla sin asignar',
                    'Fecha creación': request_poll.created.strftime('%Y-%m-%d'),
                    'Detalles':details
                }
            else:
                request_json = {
                    'ID': request_poll.id,
                    'Nombre': request_poll.request_name,
                    'Estado': request_poll.request_state,
                    'Cuadrilla': request_poll.brigade_id,
                    'Fecha creación': request_poll.created.strftime('%Y-%m-%d'),
                    'Detalles':details
                }
            
            return Response({'request_data': request_json})
        except Request.DoesNotExist:
            return Response({'error': 'La solicitud no existe'})

    elif request.method == 'POST':
        try:
            # Se obtiene el ID de la encuesta y se cambia su estado a finalizado
            request = Request.objects.get(pk=request_id)
            if request.request_state == "Finalizada":
                request.request_state = 'Cerrada'
                request.request_close = datetime.now().date()
                request.save()
                return Response({'Msj':'Solicitud cerrada con éxito'})
            else:
                return Response({'error': 'No se pudo realizar la operación'})
        except Request.DoesNotExist:
            return Response({'error': 'No se pudo realizar la operación'})
    else:
        return Response({'Msj':'Error, método no soportado'})

@api_view(['POST'])
@permission_classes([AllowAny])
def territorial_reset_password_ep(request):
    if request.method == 'POST':
        correo = request.data.get('correo')

        #Validar que el correo sea correcto
        if not re.match('^[(a-zA-Z0-9\_\-\.)]+@[(a-zA-Z0-9\_\-\.)]+\.[(a-z)]{2,4}$', correo):
            return Response({'Msj': 'El correo no es válido'})
        try:
            user = User.objects.get(email=correo)
        except User.DoesNotExist:
            return Response({'Msj': 'No existe un usuario con este correo'})

        # Se genera un token para reseteo de password con el id del usuario
        token = PasswordResetTokenGenerator().make_token(user)
        
        # Se codifica el id del usuario
        uidb64 = urlsafe_base64_encode(force_bytes(user.pk))

        # Se define la url para cambiar contraseña
        reset_url = f"http://143.198.118.203:8000/accounts/reset/{uidb64}/{token}/"

        # Se definen los elementos del correo
        subject = 'Restablecimiento de contraseña'
        message = f'Usted recibe este correo, ya que solicitó recuperar su contraseña de acceso al sistema Urban Sensor.\nPor favor haga click en el siguiente enlace:\n\n{reset_url}\n\nQue tenga un buen día.\n\nUrban Sensor'
        from_email = 'webmaster@localhost'
        to_email = [user.email]
        
        # Se envía el correo 
        send_mail(subject, message, from_email, to_email)
        return Response({'Msj':'Correo de reestablecimiento enviado correctamente'})
    else:
        return Response({'Msj': 'Método no permitido'})

@login_required
@api_view(['GET'])
def territorial_request_list_ep(request, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    
    if request.method=='GET':
        request_poll = Request.objects.order_by('-id')
        poll_json = []

        # Se filtran los detalles por el ID de la request
        for i in request_poll:
            request_data = RequestAnswer.objects.filter(request_id=i.id)
            
            # Se crea una lista para almacenar los detalles de la request
            details = []
            for j in request_data:
                details.append(j.request_answer_text)

            if i.brigade_id == 0:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':'Cuadrilla sin asignar',
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
            else:
                poll_json.append({
                    'ID':i.id,
                    'Nombre':i.request_name,
                    'Estado':i.request_state,
                    'Cuadrilla':i.brigade_id,
                    'Fecha creación': i.created.strftime('%Y-%m-%d'),
                    'Detalles':details})
        return Response({'Listado':poll_json})
    else:
        return Response({'Msj':'Error, método no soportado'})

@login_required
@api_view(['GET'])
def territorial_request_view_ep(request, request_id, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})

    if request.method == 'GET':
        try:
            request_poll = Request.objects.get(pk=request_id)
            request_data = RequestAnswer.objects.filter(request_id=request_id)

            details = []
            for j in request_data:
                field_data = Fields.objects.get(pk=j.fields_id)
                if field_data.label == 'Video':
                    path_video = 'http://174.138.53.184'+j.request_answer_text
                    details.append(path_video)
                else:
                    details.append(j.request_answer_text)

            if request_poll.brigade_id == 0:
                request_json = {
                    'ID': request_poll.id,
                    'Nombre': request_poll.request_name,
                    'Estado': request_poll.request_state,
                    'Cuadrilla': 'Cuadrilla sin asignar',
                    'Fecha creación': request_poll.created.strftime('%Y-%m-%d'),
                    'Detalles':details
                }
            else:
                request_json = {
                    'ID': request_poll.id,
                    'Nombre': request_poll.request_name,
                    'Estado': request_poll.request_state,
                    'Cuadrilla': request_poll.brigade_id,
                    'Fecha creación': request_poll.created.strftime('%Y-%m-%d'),
                    'Detalles':details
                }
            
            return Response({'request_data': request_json})
        except Request.DoesNotExist:
            return Response({'error': 'La solicitud no existe'})
    else:
        return Response({'Msj':"Error método no soportado"})

@login_required
@api_view(['GET'])
def territorial_dashboard_ep(request, format=None):
    #Validación de perfil territorial
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})
    if profiles.group_id != 2:
        return Response({'message': 'Intenta ingresar a una área para la que no tiene permisos'})

    if request.method == 'GET':
        request_sent = Request.objects.filter(Q(request_state='Derivada')).count()
        request_inprogress = Request.objects.filter(Q(request_state='Proceso')).count()
        request_finished = Request.objects.filter(Q(request_state='Finalizada')).count()

        request_data = {
            'Solicitudes enviadas':request_sent,
            'Solicitudes en proceso':request_inprogress,
            'Solicitudes finalizadas':request_finished
        }

        return Response({'Cantidad':request_data})
    else:
        return Response({'Msj':"Error método no soportado"})
    


