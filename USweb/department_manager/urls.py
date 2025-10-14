from django.urls import path
from department_manager import views

department_manager_patterns = [
    #Funciones de usuario Departamento
    path('department_main/', views.department_main,name="department_main"),
    path('department_view/<request_id>/', views.department_view,name="department_view"),
    path('department_view_read_only/<request_id>/', views.department_view_read_only,name="department_view_read_only"),
    path('department_view_read_only_admin/<request_id>/', views.department_view_read_only_admin,name="department_view_read_only_admin"),
    path('department_view_profile/', views.department_view_profile,name="department_view_profile"),
    path('department_list_derived/', views.department_list_derived,name="department_list_derived"),
    path('department_in_progress/', views.department_in_progress,name="department_in_progress"),
    path('department_finish/', views.department_finish,name="department_finish"),
    path('department_list_closed/', views.department_list_closed,name="department_list_closed"),
    path('department_derivar/', views.department_derivar,name="department_derivar"),
    path('department_cancelar/', views.department_cancelar,name="department_cancelar"),
    path('aceptar_solicitud/', views.aceptar_solicitud, name='aceptar_solicitud'),

    path('department_report_list/', views.department_report_list, name='department_report_list'),
    path('department_report_list_derived/', views.department_report_list_derived, name='department_report_list_derived'),
    path('department_report_list_progress/', views.department_report_list_progress, name='department_report_list_progress'),
    path('department_report_list_finish/', views.department_report_list_finish, name='department_report_list_finish'),
    path('department_report_list_closed/', views.department_report_list_closed, name='department_report_list_closed'),

    #Funciones de usuario Direccion
    path('management_main/', views.management_main,name="management_main"),
    path('management_view/<request_id>/', views.management_view,name="management_view"),
    path('management_view_read_only/<request_id>/', views.management_view_read_only,name="management_view_read_only"),
    path('management_view_profile/', views.management_view_profile,name="management_view_profile"),
    path('management_list_derived/', views.management_list_derived,name="management_list_derived"),
    path('management_in_progress/', views.management_in_progress,name="management_in_progress"),
    path('management_finish/', views.management_finish,name="management_finish"),
    path('management_list_closed/', views.management_list_closed,name="management_list_closed"),
    path('management_derivar/', views.management_derivar,name="management_derivar"),
    path('management_cancelar/', views.management_cancelar,name="management_cancelar"),
    path('export_request_open_excel/', views.export_request_open_excel, name='export_request_open_excel'),
    path('export_request_delivery_excel/', views.export_request_delivery_excel, name='export_request_delivery_excel'),
    path('export_request_in_progress_excel/', views.export_request_in_progress_excel, name='export_request_in_progress_excel'),
    path('export_request_finalized_excel/', views.export_request_finalized_excel, name='export_request_finalized_excel'),
    path('export_request_closed_excel/', views.export_request_closed_excel, name='export_request_closed_excel'),
] 