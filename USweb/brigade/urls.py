from django.contrib import admin
from django.urls import path
from django.views.decorators.csrf import csrf_exempt
from brigade import views

brigade_patterns = [
    path('brigade_request_view_delivery/<request_id>/', views.brigade_request_view_delivery,name="brigade_request_view_delivery"),
    path('brigade_star_process/', views.brigade_star_process,name="brigade_star_process"),
    path('brigade_decline_request/', views.brigade_decline_request,name="brigade_decline_request"),
    path('brigade_list_progress',views.brigade_list_progress,name='brigade_list_progress'), 

    
    #test
    path('brigade_list_finish',views.brigade_list_finish,name='brigade_list_finish'), 

    path('brigade_poll_view_progress/<request_id>/',views.brigade_poll_view_progress,name='brigade_poll_view_progress'), 
    path('brigade_poll_view_finish/<request_id>/',views.brigade_poll_view_finish,name='brigade_poll_view_finish'), 
    path('brigade_view_profile',views.brigade_view_profile,name='brigade_view_profile'), 
    path('brigade_cancel/<request_id>',views.brigade_cancel,name='brigade_cancel'),
    path('brigade_alert',views.brigade_alert,name='brigade_alert'), 

    path('report_list_derived/', views.report_list_derived, name='report_list_derived'),
    path('report_list_progress/', views.report_list_progress, name='report_list_progress'),
    path('report_list_finish/', views.report_list_finish, name='report_list_finish'),
    
]