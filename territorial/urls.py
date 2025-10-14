from django.urls import path
from territorial import views

territorial_patterns = [
    path('territorial_main/', views.territorial_main,name="territorial_main"),
    path('territorial_list/', views.territorial_list,name="territorial_list"),
    path('territorial_list/<page>/', views.territorial_list,name="territorial_list"),
    path('territorial_poll_view/<poll_id>/', views.territorial_poll_view,name="territorial_poll_view"),
    path('territorial_request_poll/<poll_id>/', views.territorial_request_poll,name="territorial_request_poll"),
    path('territorial_request_save/', views.territorial_request_save,name="territorial_request_save"),
    #revisar
    path('territorial_list_inprogress/', views.territorial_list_inprogress,name="territorial_list_inprogress"),
    path('territorial_list_inprogress/<page>/', views.territorial_list_inprogress,name="territorial_list_inprogress"),

    path('territorial_list_finished/', views.territorial_list_finished,name="territorial_list_finished"),
    path('territorial_list_finished/<page>/', views.territorial_list_finished,name="territorial_list_finished"),

    path('ver_perfil/', views.ver_perfil, name='ver_perfil'),

    path('territorial_list_inprogress_ep/', views.territorial_list_inprogress_ep,name="territorial_list_inprogress_ep"),

    path('territorial_poll_view_ep/<poll_id>', views.territorial_poll_view_ep,name="territorial_poll_view_ep"),

    path('territorial_list_sent_ep/', views.territorial_list_sent_ep,name="territorial_list_sent_ep"),

    path('territorial_list_finished_ep/', views.territorial_list_finished_ep,name="territorial_list_finished_ep"),

    path('territorial_see_profile_ep/', views.territorial_see_profile_ep,name="territorial_see_profile_ep"),

    path('territorial_edit_profile_ep/', views.territorial_edit_profile_ep,name="territorial_edit_profile_ep"),

    path('territorial_edit_password_ep/', views.territorial_edit_password_ep,name="territorial_edit_password_ep"),

    path('territorial_list_ep/', views.territorial_list_ep,name="territorial_list_ep"),

    path('territorial_request_save_ep/', views.territorial_request_save_ep,name="territorial_request_save_ep"),

    path('territorial_login_ep/', views.territorial_login_ep,name="territorial_login_ep"),

    path('territorial_logout_ep/', views.territorial_logout_ep,name="territorial_logout_ep"),

    path('territorial_close_request_ep/<request_id>', views.territorial_close_request_ep,name="territorial_close_request_ep"),

    path('territorial_reset_password_ep/', views.territorial_reset_password_ep,name="territorial_reset_password_ep"),

    path('territorial_request_list_ep/', views.territorial_request_list_ep,name="territorial_request_list_ep"),
    
    path('territorial_request_view_ep/<request_id>', views.territorial_request_view_ep,name="territorial_request_view_ep"),

    path('territorial_list_closed_ep/', views.territorial_list_closed_ep ,name="territorial_list_closed_ep"),

    path('territorial_list_rejected_ep/', views.territorial_list_rejected_ep ,name="territorial_list_rejected_ep"),

    path('territorial_dashboard_ep/', views.territorial_dashboard_ep ,name="territorial_dashboard_ep"),

    path('territorial_list_open_ep/', views.territorial_list_open_ep ,name="territorial_list_open_ep"),

    path('report_list_polls_territorial_active/', views.report_list_polls_territorial_active, name='report_list_polls_territorial_active'),

    path('report_list_polls_territorial_desactive/', views.report_list_polls_territorial_desactive, name='report_list_polls_territorial_desactive'),
]