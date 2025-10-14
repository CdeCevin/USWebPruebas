from django.contrib import admin
from django.urls import path
from django.views.decorators.csrf import csrf_exempt
from administrator import views

administrator_patterns = [
    path('administrator_main/', views.administrator_main,name="administrator_main"),
    path('administrator_logo_edit/', views.administrator_logo_edit,name="administrator_logo_edit"),    
    path('administrator_logo_save/', views.administrator_logo_save,name="administrator_logo_save"),    
    #gestion de usuarios
    path('administrator_users_main/', views.administrator_users_main,name="administrator_users_main"),
    path('administrator_users_save/', views.administrator_users_save,name="administrator_users_save"),        
    path('administrator_users_edit/<user_id>/<page>/', views.administrator_users_edit,name="administrator_users_edit"),    
    path('administrator_edit_save/', views.administrator_edit_save,name="administrator_edit_save"),        
    path('administrator_users_list_active/<profie_id>/', views.administrator_users_list_active,name="administrator_users_list_active"),     
    path('administrator_users_list_active/<profie_id>/<page>/', views.administrator_users_list_active,name="administrator_users_list_active"),     
    path('administrator_users_list_block/<profie_id>/', views.administrator_users_list_block,name="administrator_users_list_block"),     
    path('administrator_users_list_block/<profie_id>/<page>/', views.administrator_users_list_block,name="administrator_users_list_block"),     
    path('administrator_users_activate/<user_id>/<page>/', views.administrator_users_activate,name="administrator_users_activate"),     
    path('administrator_users_block/<user_id>/<page>/', views.administrator_users_block,name="administrator_users_block"),  
    path('administrator_view_profile_main/', views.administrator_view_profile_main,name="administrator_view_profile_main"),
    #Gestion Manuales
    path('manual_upload_direccion' ,  views.manual_upload_direccion, name = "manual_upload_direccion"),
    path('manual_upload_departamento' ,  views.manual_upload_departamento, name = "manual_upload_departamento"),
    path('manual_upload_incidente' ,  views.manual_upload_incidente, name = "manual_upload_incidente"),
    path('manual_upload_encuesta' ,  views.manual_upload_encuesta, name = "manual_upload_encuesta"),
    path('manual_upload_configuracion' ,  views.manual_upload_configuracion, name = "manual_upload_configuracion"),
    
    path('change_password/', views.change_password, name='change_password'),
    ]