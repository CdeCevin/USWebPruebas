from django.http import JsonResponse
from datetime import datetime, timedelta, date
from django.contrib import messages
from django.contrib.auth.models import User, Group
from django.contrib.auth.decorators import login_required
from django.core.paginator import EmptyPage, PageNotAnInteger, Paginator
from django.db.models import Count, Avg, Q
from django.conf import settings 
from django.http import HttpResponse, HttpResponseBadRequest, HttpResponseNotFound, HttpResponseRedirect
from django.shortcuts import render,redirect,get_object_or_404
from django.template import RequestContext
from django.urls import reverse, reverse_lazy
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from administrator.models import Config
from registration.models import Profile
from incident.models import Incident
from poll.models import Poll, Fields, Request, RequestAnswer, RequestRecord
from brigade.models import Brigade
from management.models import Management
from department.models import Deparment
from core.utils import *
from core.serializers import *
from incident.models import Incident
from django.db.models.functions import TruncMonth
from django.utils import timezone
import json
from django.db import connection
from collections import defaultdict
import locale
from django.db.models import Case, When, IntegerField
from django.utils.timezone import now
from django.db import models
import re
from django.db.models import ExpressionWrapper, F
from django.db.models.functions import Now, ExtractDay

from django.db.models.functions import TruncMonth, Concat
from department.models import Deparment
from datetime import timedelta
from django.utils import timezone
from django.db.models import Case, When, Value, IntegerField, DateField, F
from collections import defaultdict
import folium



#metodos públicos
def home(request):
    return redirect('landing')
def landing_page (request):
    return render (request, 'core/landing.html')
def inicio(request):
    return render (request, 'core/inicio.html')
#fin metodos públicos
#metodos inicio session
@login_required
def pre_check_profile(request):
    #por ahora solo esta creada pero aún no la implementaremos
    pass
@login_required
def check_group_main(request): 
    try:
        profile = Profile.objects.filter(user_id=request.user.id).get()   
    except:
        messages.add_message(request, messages.INFO, 'Error al iniciar sessión')              
        return redirect('logout')
    if profile.group_id > 0 and profile.group_id < 6:
        if profile.group_id == 1 :
            return redirect('dashboard_admin')
        if profile.group_id == 2:
            return redirect('territorial_main')
        if profile.group_id == 3:
            return redirect('departamento_main')
        if profile.group_id == 4:
            return redirect('dirección_main')
        if profile.group_id == 5:
            return redirect('dashboard_brigade')
    else:
        return redirect('logout')
#fin metodos inicio session
#dashboard
@login_required
def dashboard_admin(request):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    #keple_data
    kepler_data = Config.objects.get(pk=1)
    kepler_url = kepler_data.keppler
    #cuenta solicitudes
    direction_count = Management.objects.filter(state='Activo').count()
    department_count = Deparment.objects.filter(state='Activo').count()
    request_all_count = Request.objects.exclude(request_state='Cacelada').count()  

    # Agrupar direcciones, departamentos e incidencias por mes
    addresses_by_month = Management.objects.annotate(month=TruncMonth('created')).values('month').annotate(count=Count('id')).order_by('month')
    departments_by_month = Deparment.objects.annotate(month=TruncMonth('created')).values('month').annotate(count=Count('id')).order_by('month')
    incidents_by_month = Request.objects.annotate(month=TruncMonth('created')).values('month').annotate(count=Count('id')).order_by('month')

    # Obtener usuarios inactivos
    inactive_users = Profile.objects.annotate(
        last_login_value=Case(
            When(user__last_login__isnull=True, then=0),  # Nulos primero
            When(user__last_login__lt=timezone.now() - timedelta(days=14), then=1),  # Usuarios inactivos
            default=2, 
            output_field=IntegerField()
        )
    ).filter(last_login_value__lt=2)  # Filtrar para solo mostrar inactivos
    inactive_users = inactive_users.order_by('last_login_value')

    incidents_pending = Request.objects.filter(Q(request_state='Iniciada') | Q(request_state='Derivada') | Q(request_state='Proceso'))

    hoy = timezone.now()

    # Obtener las incidencias que se han demorado más en cerrarse
    incidencias_demoradas = Request.objects.annotate(tiempo_demorado=hoy - F('request_delivery')).filter(request_close__isnull=True, request_delivery__isnull=False, request_finish__gt=F('request_delivery')).order_by('-tiempo_demorado')[:10] 

    mes_actual = timezone.now().month
    año_actual = timezone.now().year


    hace_30_dias = hoy - timedelta(days=90)

    incidencias_por_departamento = Request.objects.filter(
        created__month=mes_actual,
        created__year=año_actual,
         deparment__state='Activo'
    ).values('deparment__deparment_name').annotate(count=Count('id'))

    labels_departamento = [incidencia['deparment__deparment_name'] for incidencia in incidencias_por_departamento]
    data_departamento = [incidencia['count'] for incidencia in incidencias_por_departamento]

    users_by_group = {
        'cuadrilla': Profile.objects.filter(group_id='5').count(),
        'departamento': Profile.objects.filter(group_id='3').count(),
        'territorial': Profile.objects.filter(group_id='2').count(),
    }
    ultimas_incidencias = Incident.objects.filter(state='Activo').order_by('-created')[:10]

    # Obtener una lista de todos los departamentos
    departamentos = Deparment.objects.filter(state='Activo')

    # Lista para almacenar la información por departamento
    data_departamentos = []
    listas_estado = []

    # Iterar sobre cada departamento para contar incidencias por estado
    for departamento in departamentos:
        # Obtener las incidencias en cada estado
        iniciadas = Request.objects.filter(request_state='Iniciada', created__gte=hace_30_dias)
        derivadas = Request.objects.filter(request_state='Derivada', created__gte=hace_30_dias)
        en_proceso = Request.objects.filter(request_state='Proceso', created__gte=hace_30_dias)
        finalizadas = Request.objects.filter(request_state='Finalizada', created__gte=hace_30_dias)
        cerradas = Request.objects.filter(request_state='Cerrada')

        # Añadir los resultados a la lista de departamentos
        data_departamentos.append({
            'name': departamento.deparment_name,
            'iniciadas': iniciadas.filter(deparment=departamento).count(),
            'derivadas': derivadas.filter(deparment=departamento).count(),
            'en_proceso': en_proceso.filter(deparment=departamento).count(),
            'finalizadas': finalizadas.filter(deparment=departamento).count(),
            'cerradas': cerradas.filter(deparment=departamento).count(),
            'total': (
                iniciadas.filter(deparment=departamento).count() +
                derivadas.filter(deparment=departamento).count() +
                en_proceso.filter(deparment=departamento).count() +
                finalizadas.filter(deparment=departamento).count() +
                cerradas.filter(deparment=departamento).count()
            ),
        })

        # Crear la lista de estados sin filtrar por departamento
        listas_estado.append({
            'iniciadas': list(iniciadas),
            'derivadas': list(derivadas),
            'en_proceso': list(en_proceso),
            'finalizadas': list(finalizadas),
            'cerradas': list(cerradas),
        })

    limite_inactividad = timezone.now() - timedelta(days=14)

    # Filtra los usuarios que no han iniciado sesión en los últimos 30 días o que están inactivos
    usuarios_ausentes = User.objects.filter(last_login__lt=limite_inactividad, is_active=True)



    ## GRaficos de linea
    # Obtener la actividad de los usuarios en los últimos 5 meses
    user_activity_data = Request.objects.filter(created__year=año_actual).exclude(deparment__id=0).values('user__first_name', 'user__last_name', 'created__month').annotate(count=Count('id'))
    completed_requests_data = Request.objects.filter(request_state='Finalizada',request_finish__year=año_actual).values('brigade__user__first_name', 'brigade__user__last_name', 'request_finish__month').annotate(count=Count('id'))
    derived_request_data = Request.objects.filter(request_delivery__year=año_actual).exclude(Q(request_delivery__isnull=True)|Q(deparment__management__id=0)).values('deparment__management__management_name','request_delivery__month').annotate(count=Count('id'))


    # Inicializar la actividad de los departamentos para los últimos 5 meses
    department_activity = {}
    brigade_activity = {}
    management_activity = {}
    months_map = {1: "Ene", 2: "Feb", 3: "Mar", 4: "Abr", 5: "May", 6: "Jun", 
                7: "Jul", 8: "Ago", 9: "Sep", 10: "Oct", 11: "Nov", 12: "Dic"}

    # Calcular meses
    last_five_months = [(mes_actual - i) % 12 for i in range(5)]
    last_five_months = last_five_months[::-1]

    for entry in user_activity_data:
        department_name = f"{entry['user__first_name']} {entry['user__last_name']}"
        month = entry['created__month']

        # Solo contar si está dentro de los últimos 5 meses
        if month in last_five_months:
            if department_name not in department_activity:
                department_activity[department_name] = [0] * 5  # Inicializa una lista para los últimos 5 meses
            index = last_five_months.index(month)
            department_activity[department_name][index] += entry['count']

    # Prepara los meses a mostrar
    display_months = [months_map[(mes_actual - i - 1) % 12 + 1] for i in range(5)][::-1]  # Últimos 5 meses

    for entry in completed_requests_data:
        brigade_name = f"{entry['brigade__user__first_name']} {entry['brigade__user__last_name']}"
        month = entry['request_finish__month']

        # Solo contar si está dentro de los últimos 5 meses
        if month in last_five_months:
            if brigade_name not in brigade_activity:
                brigade_activity[brigade_name] = [0] * 5  # Inicializa una lista para los últimos 5 meses
            index = last_five_months.index(month)
            brigade_activity[brigade_name][index] += entry['count']

    for entry in derived_request_data:
        management_name = entry['deparment__management__management_name']
        month = entry['request_delivery__month']

        if month in last_five_months:
            if management_name not in management_activity:
                management_activity[management_name] = [0] *5
            index = last_five_months.index(month)
            management_activity[management_name][index] += entry['count']

    management_totals = {management: sum(activity) for management, activity in management_activity.items()}

    top_5_management = sorted(management_totals.items(), key=lambda x: x[1], reverse=True)[:5]

    top_management_activity = {management: management_activity[management] for management, _ in top_5_management}

    # Primero, sumar el total de incidencias por cuadrilla
    brigade_totals = {brigade: sum(activity) for brigade, activity in brigade_activity.items()}

    # Luego, ordenar las cuadrillas por el total de incidencias en orden descendente y tomar las 5 primeras
    top_5_brigades = sorted(brigade_totals.items(), key=lambda x: x[1], reverse=True)[:5]

    # Ahora, recreamos el brigade_activity con solo las 5 cuadrillas más activas
    top_brigade_activity = {brigade: brigade_activity[brigade] for brigade, _ in top_5_brigades}

    # Sumar la actividad total de cada usuario (suma de incidencias por mes)
    user_totals = {user: sum(activity) for user, activity in department_activity.items()}

    # Ordenar los usuarios por el total de actividad en orden descendente y tomar los 5 primeros
    top_5_users = sorted(user_totals.items(), key=lambda x: x[1], reverse=True)[:5]

    # Crear un nuevo diccionario con solo los 5 usuarios más activos
    top_user_activity = {user: department_activity[user] for user, _ in top_5_users}

    


    ## Incidencias más repetidas y menos repetidas
    # Obtener las incidencias más repetidas
    most_repeated_incidents = Request.objects.filter(created__gte = hace_30_dias).values('deparment__management__management_name').exclude(deparment__id=0).annotate(count=Count('id')).order_by('-count')[:5]

    # Obtener las incidencias menos repetidas
    least_repeated_incidents = Request.objects.filter(created__gte = hace_30_dias).values('deparment__management__management_name').exclude(deparment__id=0).annotate(count=Count('id')).order_by('count')[:5]

    # Crear listas para etiquetas y datos
    most_repeated_labels = [incident['deparment__management__management_name'] for incident in most_repeated_incidents]
    most_repeated_data = [incident['count'] for incident in most_repeated_incidents]

    least_repeated_labels = [incident['deparment__management__management_name'] for incident in least_repeated_incidents]
    least_repeated_data = [incident['count'] for incident in least_repeated_incidents]

    # Crear un conjunto de todos los nombres de incidencias
    all_labels = set(most_repeated_labels).union(set(least_repeated_labels))

    # Usar defaultdict para asignar 0 a tipos de incidencia sin registros
    most_repeated_counts = defaultdict(int, zip(most_repeated_labels, most_repeated_data))
    least_repeated_counts = defaultdict(int, zip(least_repeated_labels, least_repeated_data))

    # Crear listas finales para las incidencias más repetidas
    final_most_repeated_labels = []
    final_most_repeated_data = []

    for label in sorted(all_labels, key=lambda x: most_repeated_counts[x], reverse=True):
        final_most_repeated_labels.append(label)
        final_most_repeated_data.append(most_repeated_counts[label])

    # Crear listas finales para las incidencias menos repetidas
    final_least_repeated_labels = []
    final_least_repeated_data = []

    for label in sorted(all_labels, key=lambda x: least_repeated_counts[x]):
        final_least_repeated_labels.append(label)
        final_least_repeated_data.append(least_repeated_counts[label])



    # Obtener el promedio de días para cerrar incidencias por cuadrilla, filtrando los datos inválidos
    brigade_data = Brigade.objects.annotate(
        full_name=Concat(F('user__first_name'), Value(' '), F('user__last_name'))
    ).filter(
        request__request_finish__gte=F('request__request_accept')  # Filtrar solo los datos donde la fecha de finalización sea mayor o igual a la de aceptación
    ).annotate(
        avg_completion_days=Avg(F('request__request_finish') - F('request__request_accept'))
    ).values('full_name', 'avg_completion_days').order_by('-avg_completion_days') [:7]

    # Crear listas para el gráfico
    brigade_labels = []
    avg_days = []

    for brigade in brigade_data:
        brigade_labels.append(brigade['full_name'])
        # Asegurarse de que no haya NoneType en los días promedio
        if brigade['avg_completion_days'] is not None:
            avg_days.append(brigade['avg_completion_days'].days)
        else:
            avg_days.append(0)

    

    
    # Casos no resueltos por mes (Iniciada, Derivada, Proceso)
    derivados = Request.objects.filter(
        request_delivery__isnull=False,
        created__year=año_actual
    ).annotate(
        month=TruncMonth('request_delivery')
    ).values('month').annotate(count=Count('id')).order_by('month')

    # Casos resueltos por mes (Finalizada, Cerrada)
    resueltos = Request.objects.filter(
        request_state__in=['Finalizada', 'Cerrada'],
        created__year=año_actual
    ).annotate(
        month=TruncMonth(
            Case(
                When(request_state='Finalizada', then='request_finish'),
                When(request_state='Cerrada', then='request_close'),
                output_field=DateField()
            )
        )
    ).values('month').annotate(count=Count('id')).order_by('month')

    # Crear un diccionario para los resultados
    casos_derivados_dict = {mes['month'].month: mes['count'] for mes in derivados}
    casos_resueltos_dict = {mes['month'].month: mes['count'] for mes in resueltos}

    # Inicializar listas para meses y conteos
    meses = []
    casos_derivados = []
    casos_resueltos = []

    # Llenar las listas con datos, usando months_map
    for mes_num in range(1, 13):
        meses.append(months_map[mes_num])  # Usar el diccionario para obtener el nombre del mes
        casos_derivados.append(casos_derivados_dict.get(mes_num, 0))  # Usa 0 si no hay datos
        casos_resueltos.append(casos_resueltos_dict.get(mes_num, 0))  # Usa 0 si no hay datos

    initial_map = folium.Map(location=[-33.440498, -70.670198], zoom_start=12)

    map_html = initial_map._repr_html_()


    context = {
        'flow': flow,
        'direction_count': direction_count,
        'department_count': department_count,
        'request_all_count': request_all_count,
        'addresses_by_month': list(addresses_by_month),
        'departments_by_month': list(departments_by_month),
        'incidents_by_month': list(incidents_by_month),
        'inactive_users': inactive_users,
        'incidencias_demoradas': incidencias_demoradas,
        'users_by_group': users_by_group,
        'incidents_pending': incidents_pending,
        'ultimas_incidencias': ultimas_incidencias,
        'labels_departamento': labels_departamento,
        'data_departamento': data_departamento,
        'departamentos': data_departamentos,
        'usuarios_ausentes': usuarios_ausentes,
        'listas_estado': listas_estado,
        'user_activity': top_user_activity, 
        'brigade_activity': top_brigade_activity,
        'management_activity': top_management_activity,
        'months': display_months,
        'most_repeated_labels': final_most_repeated_labels,
        'most_repeated_data': final_most_repeated_data,
        'least_repeated_labels': final_least_repeated_labels,
        'least_repeated_data': final_least_repeated_data,
        'brigade_labels': brigade_labels,
        'avg_days': avg_days,
        'meses': meses,
        'casos_derivados': casos_derivados,
        'casos_resueltos': casos_resueltos,
        'map': map_html,
        'kepler_url':kepler_url,
        }
    
    template_name = 'core/dashboard_admin.html'
    return render (request,template_name,context)



@login_required
def territorial_main(request):
    return render (request, 'core/territorial_main.html')
@login_required
def departamento_main(request):
    session = int(check_profile_department(request))
    if session == 0:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
        
    # Obtener la fecha actual
    current_date = timezone.now().date()

    # Obtener las 5 solicitudes más atrasadas en estado "Iniciada", "Derivada" o "Proceso"
    solicitudes_abiertas = Request.objects.filter(
        request_state__in=['Iniciada', 'Derivada', 'Proceso'],
        request_delivery__lt=current_date  # Fecha de entrega pasada
    ).select_related('poll').order_by('request_delivery')[:5]  # Ordenar por fecha de entrega y limitar a 5

    # Obtener información detallada de las solicitudes más atrasadas
    oldest_requests_data = []
    for solicitud in solicitudes_abiertas:
        try:
            brigade = solicitud.brigade
            brigade_user = User.objects.get(id=brigade.user_id)

            oldest_requests_data.append({
                'request_name': solicitud.request_name,
                'incident_type': solicitud.poll.incident.name,
                'brigade_name': brigade_user.first_name + ' ' + brigade_user.last_name,  # Nombre de la cuadrilla
                'request_delivery': solicitud.request_delivery,
                'request_state': solicitud.request_state,  # Estado de la solicitud
                'id': solicitud.id
            })
        except User.DoesNotExist:
            continue

    # Obtener las 5 incidencias más frecuentes
    top_incidents = (
        Poll.objects.values('incident__name')
        .annotate(total=Count('incident_id'))
        .order_by('-total')[:5]
    )

    # Extraer los nombres y las cantidades de las incidencias más frecuentes
    incident_names = [incident['incident__name'] for incident in top_incidents]
    incident_totals = [incident['total'] for incident in top_incidents]

    request_star_count = Request.objects.filter(request_state='Iniciada').count()
    request_delivery_count = Request.objects.filter(request_state='Derivada').count()
    request_in_progress_count = Request.objects.filter(request_state='Proceso').count()
    request_finish_count = Request.objects.filter(request_state='Finalizada').count()
    request_close_count = Request.objects.filter(request_state='Cerrada').count()

    incidencias_por_mes = Request.objects.annotate(month=TruncMonth('created')).values('month').annotate(total=Count('id')).order_by('month')


    # Obtener el mes seleccionado del formulario GET
    selected_month = request.GET.get('month')
    if selected_month:
        year = 2024
        start_date = timezone.make_aware(datetime(year, int(selected_month), 1))
        end_date = (start_date + timedelta(days=31)).replace(day=1)  # Fin del mes
    else:
        # Si no se selecciona ningún mes, se usan los últimos 6 meses por defecto
        end_date = timezone.now()
        start_date = end_date - timedelta(days=180)

    # Obtener las cuadrillas más efectivas en el rango de fechas seleccionado
    cuadrillas_efectivas = (
        Request.objects.filter(
            Q(request_state='Finalizada', request_close__range=(start_date, end_date)) |
            Q(request_state='Cerrada', request_finish__range=(start_date, end_date))
        )
        .values('brigade__user__first_name', 'brigade__user__last_name')
        .annotate(
            total_finalizadas_cerradas=Count('id'),
            total_finalizadas=Count('id', filter=Q(request_state='Finalizada', request_close__range=(start_date, end_date))),
            total_cerradas=Count('id', filter=Q(request_state='Cerrada', request_finish__range=(start_date, end_date)))
        )
        .order_by('-total_finalizadas_cerradas')[:5]
    )

    mejores_cuadrillas = [
        {
            'brigade_name': f"{cuadrilla['brigade__user__first_name']} {cuadrilla['brigade__user__last_name']}",
            'total_finalizadas_cerradas': cuadrilla['total_finalizadas_cerradas'],
            'total_finalizadas': cuadrilla['total_finalizadas'],
            'total_cerradas': cuadrilla['total_cerradas']
        }
        for cuadrilla in cuadrillas_efectivas
    ]

    # Definir los meses para el selector
    meses = [
        {'label': 'Enero', 'value': '1'},
        {'label': 'Febrero', 'value': '2'},
        {'label': 'Marzo', 'value': '3'},
        {'label': 'Abril', 'value': '4'},
        {'label': 'Mayo', 'value': '5'},
        {'label': 'Junio', 'value': '6'},
        {'label': 'Julio', 'value': '7'},
        {'label': 'Agosto', 'value': '8'},
        {'label': 'Septiembre', 'value': '9'},
        {'label': 'Octubre', 'value': '10'},
        {'label': 'Noviembre', 'value': '11'},
        {'label': 'Diciembre', 'value': '12'},
    ]

    # Obtener las solicitudes finalizadas y cerradas de los últimos 6 meses
    start_date = timezone.now() - timedelta(days=180)  # Últimos 6 meses
    end_date = timezone.now()

    # Filtrar por solicitudes finalizadas y cerradas, y agruparlas por mes
    solicitudes_finalizadas = (
        Request.objects.filter(
            request_finish__range=(start_date, end_date)
        )
        .annotate(month=TruncMonth('request_finish'))
        .values('month')
        .annotate(total=Count('id'))
        .order_by('month')
    )

    solicitudes_cerradas = (
        Request.objects.filter(
            request_close__range=(start_date, end_date)
        )
        .annotate(month=TruncMonth('request_close'))
        .values('month')
        .annotate(total=Count('id'))
        .order_by('month')
    )

    # Preparar los datos para el gráfico
    finalizadas_por_mes = {sol['month'].strftime('%Y-%m'): sol['total'] for sol in solicitudes_finalizadas}
    cerradas_por_mes = {sol['month'].strftime('%Y-%m'): sol['total'] for sol in solicitudes_cerradas}

    # Asegurarse de que cada mes tenga un valor, incluso si no hubo solicitudes
    fechas_completas = [timezone.now() - timedelta(days=30 * i) for i in range(6)]
    fechas_completas.reverse()

    finalizadas_data = []
    cerradas_data = []
    total_data = []

    # Generar los datos finales para cada mes
    for fecha in fechas_completas:
        str_fecha = fecha.strftime('%Y-%m')
        finalizadas = finalizadas_por_mes.get(str_fecha, 0)
        cerradas = cerradas_por_mes.get(str_fecha, 0)
        finalizadas_data.append(finalizadas)
        cerradas_data.append(cerradas)
        total_data.append(finalizadas + cerradas) # Usar .get() en el diccionario de cerradas...

    tabla_datos = []
    for fecha in fechas_completas:
        str_fecha = fecha.strftime('%Y-%m')
        finalizadas = finalizadas_por_mes.get(str_fecha, 0)
        cerradas = cerradas_por_mes.get(str_fecha, 0)
        total = finalizadas + cerradas
        tabla_datos.append((str_fecha, finalizadas, cerradas, total))

    # Obtener la fecha de hace 6 meses desde hoy
    seis_meses_atras = now() - timedelta(days=6 * 30)

    # Filtrar las solicitudes con estado 'Derivada' y que tienen request_delivery dentro de los últimos 6 meses
    solicitudes_derivadas = Request.objects.filter(
        request_delivery__gte=seis_meses_atras,
        request_state='Derivada'
    )

    # Obtener las incidencias más derivadas a través de la relación poll -> incident
    incidencias_derivadas = solicitudes_derivadas.values(
        'poll__incident__name'  # Acceso a incident name a través de poll
    ).annotate(
        count_derivadas=Count('id')  # Contar cuántas veces se ha derivado cada incidencia
    ).order_by('-count_derivadas')[:5]  # Obtener las 5 incidencias más derivadas

    # Obtener los nombres de las incidencias y la cantidad de veces que fueron derivadas
    incidencias_nombres = [inc['poll__incident__name'] for inc in incidencias_derivadas]
    derivadas_count = [inc['count_derivadas'] for inc in incidencias_derivadas]


    # Obtener la fecha de hace 6 meses desde hoy
    seis_meses_atras = now() - timedelta(days=6 * 30)

    # Filtrar las solicitudes con estado 'Proceso' y que tienen request_accept dentro de los últimos 6 meses
    solicitudes_en_proceso = Request.objects.filter(
        request_accept__gte=seis_meses_atras,
        request_state='Proceso'
    )

    # Obtener las incidencias más en proceso a través de la relación poll -> incident
    incidencias_en_proceso = solicitudes_en_proceso.values(
        'poll__incident__name'  # Acceso al nombre de la incidencia a través de poll
    ).annotate(
        count_proceso=Count('id')  # Contar cuántas veces se ha procesado cada incidencia
    ).order_by('-count_proceso')[:5]  # Obtener las 5 incidencias más en proceso

    # Obtener los nombres de las incidencias y la cantidad de veces que estuvieron en proceso
    incidencias_nombres = [inc['poll__incident__name'] for inc in incidencias_en_proceso]
    proceso_count = [inc['count_proceso'] for inc in incidencias_en_proceso]

    # Obtener la fecha de hace 6 meses desde hoy
    seis_meses_atras = now() - timedelta(days=6 * 30)

    # Filtrar las solicitudes con estado 'Derivada' y que tienen request_delivery dentro de los últimos 6 meses
    solicitudes_derivadas = Request.objects.filter(
        request_delivery__gte=seis_meses_atras,
        request_state='Derivada'
    )

    # Obtener las incidencias más derivadas a través de la relación poll -> incident
    incidencias_derivadas = solicitudes_derivadas.values(
        'poll__incident__name'
    ).annotate(
        count_derivadas=Count('id')
    ).order_by('-count_derivadas')[:5]

    # Crear una lista de diccionarios para incidencias derivadas
    derivadas_list = [
        {'nombre': inc['poll__incident__name'], 'count': inc['count_derivadas']}
        for inc in incidencias_derivadas
    ]

    # Filtrar las solicitudes con estado 'Proceso' y que tienen request_accept dentro de los últimos 6 meses
    solicitudes_en_proceso = Request.objects.filter(
        request_accept__gte=seis_meses_atras,
        request_state='Proceso'
    )

    # Obtener las incidencias más en proceso a través de la relación poll -> incident
    incidencias_en_proceso = solicitudes_en_proceso.values(
        'poll__incident__name'
    ).annotate(
        count_proceso=Count('id')
    ).order_by('-count_proceso')[:5]

    # Crear una lista de diccionarios para incidencias en proceso
    proceso_list = [
        {'nombre': inc['poll__incident__name'], 'count': inc['count_proceso']}
        for inc in incidencias_en_proceso
    ]

    # Listado de solicitudes rechazadas con contador de días de atraso
    solicitudes_rechazadas = (
        Request.objects
        .filter(request_state='Iniciada')
        .select_related('poll')
        .filter(requestrecord__request_record_kind='Rechazada')
        .annotate(
            dias_atraso=ExpressionWrapper(
                ExtractDay(Now() - F('updated')),
                output_field=IntegerField()
            )
        )
    )

    # Listado de incidencias con fecha formateada y cálculo de días de atraso
    incidencias_por_fecha = []
    for incidencia in (
        Request.objects
        .filter(request_state__in=['Iniciada', 'Proceso', 'Derivada'])
        .annotate(dias_atraso=(now() - F('updated')))
        .order_by('updated')
    ):
        # Formatear la fecha en "DD/MM/YYYY"
        fecha_formateada = incidencia.updated.strftime("%d/%m/%Y")
        
        # Calcular días de atraso en función de la fecha actual y el estado actual
        dias_atraso = (now() - incidencia.updated).days
        incidencia_info = {
            'incidencia': incidencia,
            'fecha_formateada': fecha_formateada,
            'dias_atraso': dias_atraso
        }
        incidencias_por_fecha.append(incidencia_info)

    # Fechas de los últimos 6 meses
    start_date = timezone.now() - timedelta(days=180)

    # Filtrar solicitudes atrasadas en los estados Derivada, Iniciada o Proceso
    cuadrillas_atrasadas = (
        Request.objects.filter(
            request_state__in=["Derivada", "Iniciada", "Proceso"]
        )
        .annotate(
            fecha_referencia=Case(
                When(request_state='Derivada', then='request_delivery'),
                When(request_state__in=['Iniciada', 'Proceso'], then='request_accept'),
                output_field=models.DateTimeField()
            )
        )
        .filter(fecha_referencia__gte=start_date)  # Filtrar por la fecha de referencia
        .select_related('brigade__user')  # Aseguramos que se carguen los datos del usuario
        .values('brigade_id', 'brigade__user__first_name', 'brigade__user__last_name')
        .annotate(
            total_atrasadas=Count('id'),
            total_derivadas=Count(Case(When(request_state='Derivada', then=1))),
            total_iniciadas=Count(Case(When(request_state='Iniciada', then=1))),
            total_procesos=Count(Case(When(request_state='Proceso', then=1))),
        )
        .order_by('-total_atrasadas')[:5]  # Top 5 más atrasadas
    )

    # Obtener nombres de las cuadrillas y armar la lista
    nombres = []
    totals_derivadas = []
    totals_iniciadas = []
    totals_procesos = []

    for cuadrilla in cuadrillas_atrasadas:
        nombres.append(f"{cuadrilla['brigade__user__first_name']} {cuadrilla['brigade__user__last_name']}")
        totals_derivadas.append(cuadrilla['total_derivadas'])
        totals_iniciadas.append(cuadrilla['total_iniciadas'])
        totals_procesos.append(cuadrilla['total_procesos'])

    # Fechas de los últimos 6 meses
    start_date = timezone.now() - timedelta(days=180)

    # Filtrar solicitudes atrasadas en los estados Derivada, Iniciada o Proceso
    cuadrillas_atrasadas = (
        Request.objects.filter(
            request_state__in=["Derivada", "Iniciada", "Proceso"]
        )
        .annotate(
            fecha_referencia=Case(
                When(request_state='Derivada', then='request_delivery'),
                When(request_state__in=['Iniciada', 'Proceso'], then='request_accept'),
                output_field=models.DateTimeField()
            )
        )
        .filter(fecha_referencia__gte=start_date)  # Filtrar por la fecha de referencia
        .select_related('brigade__user')  # Aseguramos que se carguen los datos del usuario
        .values('brigade_id', 'brigade__user__first_name', 'brigade__user__last_name')
        .annotate(
            total_atrasadas=Count('id'),
            total_derivadas=Count(Case(When(request_state='Derivada', then=1))),
            total_iniciadas=Count(Case(When(request_state='Iniciada', then=1))),
            total_procesos=Count(Case(When(request_state='Proceso', then=1))),
        )
        .order_by('-total_atrasadas')[:5]  # Top 5 más atrasadas
    )


    context = {
        'request_star_count': request_star_count,
        'request_delivery_count': request_delivery_count,
        'request_in_progress_count': request_in_progress_count,
        'request_finish_count': request_finish_count,
        'request_close_count': request_close_count,
        'solicitudes_abiertas': oldest_requests_data,
        'incident_names': incident_names,
        'incident_totals': incident_totals,
        'top_incidents': top_incidents, 
        'mejores_cuadrillas': mejores_cuadrillas,  # Cuadrillas más efectivas
        'meses': meses,
        'selected_month': selected_month,
        'fechas': [fecha.strftime('%Y-%m') for fecha in fechas_completas],
        'finalizadas_data': finalizadas_data, 
        'cerradas_data': cerradas_data,
        'total_data': total_data,
        'incidencias_nombres': incidencias_nombres,
        'derivadas_count': derivadas_count,
        'proceso_count': proceso_count,
        'solicitudes_rechazadas': solicitudes_rechazadas,
        'incidencias_por_fecha': incidencias_por_fecha,
        'nombres': nombres,
        'totals_derivadas': totals_derivadas,
        'totals_iniciadas': totals_iniciadas,
        'totals_procesos': totals_procesos,
        'tabla_datos': tabla_datos,
        'incidencias_derivadas': derivadas_list,
        'incidencias_en_proceso': proceso_list,
        'cuadrillas_atrasadas': cuadrillas_atrasadas,
    }
    template_name = 'core/dashboard_department.html'
    return render (request,template_name,context)


@login_required
def dirección_main(request):
    session = int(check_profile_management(request))
    if session == 0:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a un área para la que no tiene permisos')
        return redirect('logout')

    # Obtener la fecha actual
    current_date = timezone.now().date()

    # Obtener las 5 solicitudes más atrasadas en estado "Iniciada", "Derivada" o "Proceso"
    solicitudes_abiertas = Request.objects.filter(
        request_state__in=['Iniciada', 'Derivada', 'Proceso'],
        request_delivery__lt=current_date  # Fecha de entrega pasada
    ).select_related('poll').order_by('request_delivery')[:5]  # Ordenar por fecha de entrega y limitar a 5

    # Obtener información detallada de las solicitudes más atrasadas
    oldest_requests_data = []
    for solicitud in solicitudes_abiertas:
        try:
            brigade = solicitud.brigade
            brigade_user = User.objects.get(id=brigade.user_id)

            oldest_requests_data.append({
                'request_name': solicitud.request_name,
                'incident_type': solicitud.poll.incident.name,
                'brigade_name': brigade_user.first_name + ' ' + brigade_user.last_name,  # Nombre de la cuadrilla
                'request_delivery': solicitud.request_delivery,
                'request_state': solicitud.request_state,  # Estado de la solicitud
                'id': solicitud.id
            })
        except User.DoesNotExist:
            continue

    # Obtener las 5 incidencias más frecuentes
    top_incidents = (
        Poll.objects.values('incident__name')
        .annotate(total=Count('incident_id'))
        .order_by('-total')[:5]
    )

    # Extraer los nombres y las cantidades de las incidencias más frecuentes
    incident_names = [incident['incident__name'] for incident in top_incidents]
    incident_totals = [incident['total'] for incident in top_incidents]

    request_star_count = Request.objects.filter(request_state='Iniciada').count()
    request_delivery_count = Request.objects.filter(request_state='Derivada').count()
    request_in_progress_count = Request.objects.filter(request_state='Proceso').count()
    request_finish_count = Request.objects.filter(request_state='Finalizada').count()
    request_close_count = Request.objects.filter(request_state='Cerrada').count()

    incidencias_por_mes = Request.objects.annotate(month=TruncMonth('created')).values('month').annotate(total=Count('id')).order_by('month')


    # Obtener el mes seleccionado del formulario GET
    selected_month = request.GET.get('month')
    if selected_month:
        year = 2024
        start_date = timezone.make_aware(datetime(year, int(selected_month), 1))
        end_date = (start_date + timedelta(days=31)).replace(day=1)  # Fin del mes
    else:
        # Si no se selecciona ningún mes, se usan los últimos 6 meses por defecto
        end_date = timezone.now()
        start_date = end_date - timedelta(days=180)

    # Obtener las cuadrillas más efectivas en el rango de fechas seleccionado
    cuadrillas_efectivas = (
        Request.objects.filter(
            Q(request_state='Finalizada', request_close__range=(start_date, end_date)) |
            Q(request_state='Cerrada', request_finish__range=(start_date, end_date))
        )
        .values('brigade__user__first_name', 'brigade__user__last_name')
        .annotate(
            total_finalizadas_cerradas=Count('id'),
            total_finalizadas=Count('id', filter=Q(request_state='Finalizada', request_close__range=(start_date, end_date))),
            total_cerradas=Count('id', filter=Q(request_state='Cerrada', request_finish__range=(start_date, end_date)))
        )
        .order_by('-total_finalizadas_cerradas')[:5]
    )

    mejores_cuadrillas = [
        {
            'brigade_name': f"{cuadrilla['brigade__user__first_name']} {cuadrilla['brigade__user__last_name']}",
            'total_finalizadas_cerradas': cuadrilla['total_finalizadas_cerradas'],
            'total_finalizadas': cuadrilla['total_finalizadas'],
            'total_cerradas': cuadrilla['total_cerradas']
        }
        for cuadrilla in cuadrillas_efectivas
    ]

    # Definir los meses para el selector
    meses = [
        {'label': 'Enero', 'value': '1'},
        {'label': 'Febrero', 'value': '2'},
        {'label': 'Marzo', 'value': '3'},
        {'label': 'Abril', 'value': '4'},
        {'label': 'Mayo', 'value': '5'},
        {'label': 'Junio', 'value': '6'},
        {'label': 'Julio', 'value': '7'},
        {'label': 'Agosto', 'value': '8'},
        {'label': 'Septiembre', 'value': '9'},
        {'label': 'Octubre', 'value': '10'},
        {'label': 'Noviembre', 'value': '11'},
        {'label': 'Diciembre', 'value': '12'},
    ]

    # Obtener las solicitudes finalizadas y cerradas de los últimos 6 meses
    start_date = timezone.now() - timedelta(days=180)  # Últimos 6 meses
    end_date = timezone.now()

    # Filtrar por solicitudes finalizadas y cerradas, y agruparlas por mes
    solicitudes_finalizadas = (
        Request.objects.filter(
            request_finish__range=(start_date, end_date)
        )
        .annotate(month=TruncMonth('request_finish'))
        .values('month')
        .annotate(total=Count('id'))
        .order_by('month')
    )

    solicitudes_cerradas = (
        Request.objects.filter(
            request_close__range=(start_date, end_date)
        )
        .annotate(month=TruncMonth('request_close'))
        .values('month')
        .annotate(total=Count('id'))
        .order_by('month')
    )

    # Preparar los datos para el gráfico
    finalizadas_por_mes = {sol['month'].strftime('%Y-%m'): sol['total'] for sol in solicitudes_finalizadas}
    cerradas_por_mes = {sol['month'].strftime('%Y-%m'): sol['total'] for sol in solicitudes_cerradas}

    # Asegurarse de que cada mes tenga un valor, incluso si no hubo solicitudes
    fechas_completas = [timezone.now() - timedelta(days=30 * i) for i in range(6)]
    fechas_completas.reverse()

    finalizadas_data = []
    cerradas_data = []
    total_data = []

    # Generar los datos finales para cada mes
    for fecha in fechas_completas:
        str_fecha = fecha.strftime('%Y-%m')
        finalizadas = finalizadas_por_mes.get(str_fecha, 0)
        cerradas = cerradas_por_mes.get(str_fecha, 0)
        finalizadas_data.append(finalizadas)
        cerradas_data.append(cerradas)
        total_data.append(finalizadas + cerradas) # Usar .get() en el diccionario de cerradas...

    tabla_datos = []
    for fecha in fechas_completas:
        str_fecha = fecha.strftime('%Y-%m')
        finalizadas = finalizadas_por_mes.get(str_fecha, 0)
        cerradas = cerradas_por_mes.get(str_fecha, 0)
        total = finalizadas + cerradas
        tabla_datos.append((str_fecha, finalizadas, cerradas, total))

    # Obtener la fecha de hace 6 meses desde hoy
    seis_meses_atras = now() - timedelta(days=6 * 30)

    # Filtrar las solicitudes con estado 'Derivada' y que tienen request_delivery dentro de los últimos 6 meses
    solicitudes_derivadas = Request.objects.filter(
        request_delivery__gte=seis_meses_atras,
        request_state='Derivada'
    )

    # Obtener las incidencias más derivadas a través de la relación poll -> incident
    incidencias_derivadas = solicitudes_derivadas.values(
        'poll__incident__name'  # Acceso a incident name a través de poll
    ).annotate(
        count_derivadas=Count('id')  # Contar cuántas veces se ha derivado cada incidencia
    ).order_by('-count_derivadas')[:5]  # Obtener las 5 incidencias más derivadas

    # Obtener los nombres de las incidencias y la cantidad de veces que fueron derivadas
    incidencias_nombres = [inc['poll__incident__name'] for inc in incidencias_derivadas]
    derivadas_count = [inc['count_derivadas'] for inc in incidencias_derivadas]


    # Obtener la fecha de hace 6 meses desde hoy
    seis_meses_atras = now() - timedelta(days=6 * 30)

    # Filtrar las solicitudes con estado 'Proceso' y que tienen request_accept dentro de los últimos 6 meses
    solicitudes_en_proceso = Request.objects.filter(
        request_accept__gte=seis_meses_atras,
        request_state='Proceso'
    )

    # Obtener las incidencias más en proceso a través de la relación poll -> incident
    incidencias_en_proceso = solicitudes_en_proceso.values(
        'poll__incident__name'  # Acceso al nombre de la incidencia a través de poll
    ).annotate(
        count_proceso=Count('id')  # Contar cuántas veces se ha procesado cada incidencia
    ).order_by('-count_proceso')[:5]  # Obtener las 5 incidencias más en proceso

    # Obtener los nombres de las incidencias y la cantidad de veces que estuvieron en proceso
    incidencias_nombres = [inc['poll__incident__name'] for inc in incidencias_en_proceso]
    proceso_count = [inc['count_proceso'] for inc in incidencias_en_proceso]

    # Obtener la fecha de hace 6 meses desde hoy
    seis_meses_atras = now() - timedelta(days=6 * 30)

    # Filtrar las solicitudes con estado 'Derivada' y que tienen request_delivery dentro de los últimos 6 meses
    solicitudes_derivadas = Request.objects.filter(
        request_delivery__gte=seis_meses_atras,
        request_state='Derivada'
    )

    # Obtener las incidencias más derivadas a través de la relación poll -> incident
    incidencias_derivadas = solicitudes_derivadas.values(
        'poll__incident__name'
    ).annotate(
        count_derivadas=Count('id')
    ).order_by('-count_derivadas')[:5]

    # Crear una lista de diccionarios para incidencias derivadas
    derivadas_list = [
        {'nombre': inc['poll__incident__name'], 'count': inc['count_derivadas']}
        for inc in incidencias_derivadas
    ]

    # Filtrar las solicitudes con estado 'Proceso' y que tienen request_accept dentro de los últimos 6 meses
    solicitudes_en_proceso = Request.objects.filter(
        request_accept__gte=seis_meses_atras,
        request_state='Proceso'
    )

    # Obtener las incidencias más en proceso a través de la relación poll -> incident
    incidencias_en_proceso = solicitudes_en_proceso.values(
        'poll__incident__name'
    ).annotate(
        count_proceso=Count('id')
    ).order_by('-count_proceso')[:5]

    # Crear una lista de diccionarios para incidencias en proceso
    proceso_list = [
        {'nombre': inc['poll__incident__name'], 'count': inc['count_proceso']}
        for inc in incidencias_en_proceso
    ]

    # Listado de solicitudes rechazadas con contador de días de atraso
    solicitudes_rechazadas = (
        Request.objects
        .filter(request_state='Iniciada')
        .select_related('poll')
        .filter(requestrecord__request_record_kind='Rechazada')
        .annotate(
            dias_atraso=ExpressionWrapper(
                ExtractDay(Now() - F('updated')),
                output_field=IntegerField()
            )
        )
    )
    # Listado de incidencias con fecha formateada y cálculo de días de atraso
    incidencias_por_fecha = []
    for incidencia in (
        Request.objects
        .filter(request_state__in=['Iniciada', 'Proceso', 'Derivada'])
        .annotate(dias_atraso=(now() - F('updated')))
        .order_by('updated')
    ):
        # Formatear la fecha en "DD/MM/YYYY"
        fecha_formateada = incidencia.updated.strftime("%d/%m/%Y")
        
        # Calcular días de atraso en función de la fecha actual y el estado actual
        dias_atraso = (now() - incidencia.updated).days
        incidencia_info = {
            'incidencia': incidencia,
            'fecha_formateada': fecha_formateada,
            'dias_atraso': dias_atraso
        }
        incidencias_por_fecha.append(incidencia_info)

    # Fechas de los últimos 6 meses
    start_date = timezone.now() - timedelta(days=180)

    # Filtrar solicitudes atrasadas en los estados Derivada, Iniciada o Proceso
    cuadrillas_atrasadas = (
        Request.objects.filter(
            request_state__in=["Derivada", "Iniciada", "Proceso"]
        )
        .annotate(
            fecha_referencia=Case(
                When(request_state='Derivada', then='request_delivery'),
                When(request_state__in=['Iniciada', 'Proceso'], then='request_accept'),
                output_field=models.DateTimeField()
            )
        )
        .filter(fecha_referencia__gte=start_date)  # Filtrar por la fecha de referencia
        .select_related('brigade__user')  # Aseguramos que se carguen los datos del usuario
        .values('brigade_id', 'brigade__user__first_name', 'brigade__user__last_name')
        .annotate(
            total_atrasadas=Count('id'),
            total_derivadas=Count(Case(When(request_state='Derivada', then=1))),
            total_iniciadas=Count(Case(When(request_state='Iniciada', then=1))),
            total_procesos=Count(Case(When(request_state='Proceso', then=1))),
        )
        .order_by('-total_atrasadas')[:5]  # Top 5 más atrasadas
    )

    # Obtener nombres de las cuadrillas y armar la lista
    nombres = []
    totals_derivadas = []
    totals_iniciadas = []
    totals_procesos = []

    for cuadrilla in cuadrillas_atrasadas:
        nombres.append(f"{cuadrilla['brigade__user__first_name']} {cuadrilla['brigade__user__last_name']}")
        totals_derivadas.append(cuadrilla['total_derivadas'])
        totals_iniciadas.append(cuadrilla['total_iniciadas'])
        totals_procesos.append(cuadrilla['total_procesos'])

    # Fechas de los últimos 6 meses
    start_date = timezone.now() - timedelta(days=180)

    # Filtrar solicitudes atrasadas en los estados Derivada, Iniciada o Proceso
    cuadrillas_atrasadas = (
        Request.objects.filter(
            request_state__in=["Derivada", "Iniciada", "Proceso"]
        )
        .annotate(
            fecha_referencia=Case(
                When(request_state='Derivada', then='request_delivery'),
                When(request_state__in=['Iniciada', 'Proceso'], then='request_accept'),
                output_field=models.DateTimeField()
            )
        )
        .filter(fecha_referencia__gte=start_date)  # Filtrar por la fecha de referencia
        .select_related('brigade__user')  # Aseguramos que se carguen los datos del usuario
        .values('brigade_id', 'brigade__user__first_name', 'brigade__user__last_name')
        .annotate(
            total_atrasadas=Count('id'),
            total_derivadas=Count(Case(When(request_state='Derivada', then=1))),
            total_iniciadas=Count(Case(When(request_state='Iniciada', then=1))),
            total_procesos=Count(Case(When(request_state='Proceso', then=1))),
        )
        .order_by('-total_atrasadas')[:5]  # Top 5 más atrasadas
    )


    context = {
        'request_star_count': request_star_count,
        'request_delivery_count': request_delivery_count,
        'request_in_progress_count': request_in_progress_count,
        'request_finish_count': request_finish_count,
        'request_close_count': request_close_count,
        'solicitudes_abiertas': oldest_requests_data,
        'incident_names': incident_names,
        'incident_totals': incident_totals,
        'top_incidents': top_incidents, 
        'mejores_cuadrillas': mejores_cuadrillas,  # Cuadrillas más efectivas
        'meses': meses,
        'selected_month': selected_month,
        'fechas': [fecha.strftime('%Y-%m') for fecha in fechas_completas],
        'finalizadas_data': finalizadas_data, 
        'cerradas_data': cerradas_data,
        'total_data': total_data,
        'incidencias_nombres': incidencias_nombres,
        'derivadas_count': derivadas_count,
        'proceso_count': proceso_count,
        'solicitudes_rechazadas': solicitudes_rechazadas,
        'incidencias_por_fecha': incidencias_por_fecha,
        'nombres': nombres,
        'totals_derivadas': totals_derivadas,
        'totals_iniciadas': totals_iniciadas,
        'totals_procesos': totals_procesos,
        'tabla_datos': tabla_datos,
        'incidencias_derivadas': derivadas_list,
        'incidencias_en_proceso': proceso_list,
        'cuadrillas_atrasadas': cuadrillas_atrasadas,
    }

    template_name = 'core/dashboard_direccion.html'
    return render(request, template_name, context)

#Solo para probrar
@login_required
def cuadrilla_main(request,page=None):  
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        profile = None
    if profiles.group_id != 5:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    #datos cuadrilla
    try:
        brigade_data = Brigade.objects.get(user_id=request.user.id)
    except Brigade.DoesNotExist:
        messages.add_message(request, messages.INFO, 'Hubo un error')
        return redirect('login')
    #cuenta solicitudes
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

    incident_list = Request.objects.filter(request_state='Derivada').filter(brigade_id=brigade_data.id)
    page = request.GET.get('page')
    paginator = Paginator(incident_list, 10) 
    request_activate_list = paginator.get_page(page)
    template_name = 'core/cuadrilla_main.html'    
    return render(request,template_name,{'profiles':profiles,'request_activate_list':request_activate_list,'incident_list':incident_list, 'username': request.user.username,'request_delivery_count':request_delivery_count,'request_in_progress_count':request_in_progress_count,'request_end_count':request_end_count})

#servicio que deben consumir los mapas
@api_view(['GET'])
def reuqest_data_map(request, format=None):
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Hubo un error'})
    if profiles.group_id != 99:
        return Response({'message': 'Hubo un error'})   
    if request.method=='GET':
        request_all = Request.objects.exclude(request_state='Cancelada').order_by('request_date')
        request_all_json = {}
        for r in request_all:
            pool_data = Poll.objects.get(pk=r.poll_id)
            iniciden_data = Incident.objects.get(pk=pool_data.incident_id)
            poll_filed_array = Fields.objects.filter(poll_id=r.poll_id)
            for p in poll_filed_array:
                if p.name == 'incidence_latitud':
                    id_lat = p.id
                if p.name == 'incidence_longitud':
                    id_lon = p.id 
            poll_answer_lat_data = RequestAnswer.objects.filter(fields_id=id_lat).filter(request_id=r.id).first()
            try:
                poll_answer_lat = poll_answer_lat_data.request_answer_text 
            except:
                poll_answer_lat = 0
            poll_answer_lon_data = RequestAnswer.objects.filter(fields_id=id_lon).filter(request_id=r.id).first()
            try:
                poll_answer_lon = poll_answer_lon_data.request_answer_text
            except:
                poll_answer_lon = 0                
            request_all_json[r.id] = []
            request_all_json[r.id].append({
                'request_name':r.request_name,
                'request_date':r.request_date,
                'request_delivery':r.request_delivery,
                'request_accept':r.request_accept,
                'request_close':r.request_close,
                'request_finish':r.request_finish,
                'request_state':r.request_state,
                'request_type':iniciden_data.name,
                'request_lat':poll_answer_lat,
                'request_lon':poll_answer_lon,                               
                })
        return Response(request_all_json)    
    else:
        return Response({'Msj':'Hubo un error'})

#retornar la base de datos
@api_view(['GET'])
def request_data_all(request, format=None):
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Hubo un error'})
    if profiles.group_id != 2:
        return Response({'message': 'Hubo un error'})   
    if request.method=='GET':
        #trae el contenido de la tabla Incident
        incident_all = Incident.objects.exclude(state='Bloqueado').order_by('id')
        serializer_incident = IncidentSerializer(incident_all, many=True) 
        
        #trae el contido de la tabla Poll
        poll_all = Poll.objects.filter(state='Activo').order_by('id')
        serializer_poll = PollSerializer(poll_all, many=True)        
        
        #trae el contido de la tabla Field
        fields_all = Fields.objects.filter(state='Activo').order_by('id')
        serializer_field = FieldSerializer(fields_all, many=True) 

         # Trae el contenido de la tabla Request
        request_all = Request.objects.all().order_by('id')
        serializer_request = RequestSerializer(request_all, many=True)
        
        # Trae el contenido de la tabla RequestAnswer
        request_answer_all = RequestAnswer.objects.all().order_by('id')
        serializer_request_answer = RequestAnswerSerializer(request_answer_all, many=True)

        return Response({'incident':serializer_incident.data,'poll':serializer_poll.data,'field':serializer_field.data,'request': serializer_request.data,'request_answer': serializer_request_answer.data})           
    else:
        return Response({'Msj':'Hubo un error'})
    
@api_view(['GET'])
def latest_request_id(request, format=None):
    try:
        profiles = Profile.objects.get(user_id=request.user.id)
    except Profile.DoesNotExist:
        return Response({'message': 'Hubo un error'}, status=400)
    
    if profiles.group_id != 2:
        return Response({'message': 'Hubo un error'}, status=403)   
    
    if request.method == 'GET':
        try:
            latest_request = Request.objects.latest('id')  # Obtiene el último registro basado en el campo 'id'
            serializer = RequestIdSerializer({'id': latest_request.id})
            return Response({'latest_id': serializer.data['id']})
        except Request.DoesNotExist:
            return Response({'latest_id': None}, status=404)
    else:
        return Response({'Msj': 'Método no permitido'}, status=405)

@login_required
def dashboard_brigade(request,page=None):  
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        profile = None
    if profiles.group_id != 5:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('check_group_main')
    #datos cuadrilla
    try:
        brigade_data = Brigade.objects.get(user_id=request.user.id)
    except Brigade.DoesNotExist:
        messages.add_message(request, messages.INFO, 'Hubo un error')
        return redirect('login')
    #cuenta solicitudes
    request_delivery_count = Request.objects.filter(request_state='Derivada').filter(brigade_id=brigade_data.id).count()
    request_in_progress_count = Request.objects.filter(request_state='Proceso').filter(brigade_id=brigade_data.id).count()
    request_end_count = Request.objects.filter(request_state='Finalizada').filter(brigade_id=brigade_data.id).count()   

    # Listado de solicitudes con cálculo de días
    today = timezone.now().date()

    incident_list = Request.objects.filter(request_state='Proceso', brigade_id=brigade_data.id).order_by('-request_accept')
    for incident in incident_list:
        incident.days_since_accept = (today - incident.request_accept).days

    derived_list = Request.objects.filter(request_state='Derivada', brigade_id=brigade_data.id).order_by('-request_delivery')
    for derived in derived_list:
        derived.days_since_delivery = (today - derived.request_delivery).days

    context = {
        'request_delivery_count' : request_delivery_count,
        'request_in_progress_count' : request_in_progress_count,
        'request_end_count' : request_end_count,
        'incident_list' :incident_list,
        'derived_list' : derived_list,
    }
    template_name = 'core/dashboard_brigade.html'    
    return render(request,template_name,context)