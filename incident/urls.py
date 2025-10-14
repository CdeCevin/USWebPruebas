from django.urls import path
from incident import views

incident_patterns = [
    path('incident_add/', views.incident_add,name="incident_add"),
    path('incident_list_active/', views.incident_list_active,name="incident_list_active"),
    path('incident_list_active/<page>/', views.incident_list_active,name="incident_list_active"),
    path('incident_list_deactive', views.incident_list_deactive,name="incident_list_deactive"),
    path('incident_block/<incident_id>/', views.incident_block,name="incident_block"),
    path('incident_activate/<incident_id>/', views.incident_activate,name="incident_activate"),
    path('incident_list_deactive/<page>/', views.incident_list_deactive,name="incident_list_deactive"),
    path('incident_edit/<incident_id>/', views.incident_edit,name="incident_edit"),
    path('incident_edit_save/', views.incident_edit_save,name="incident_edit_save"),
    path('incident_8010/', views.incident_8010,name="incident_8010"),

    path('report_incident_active/', views.report_incident_active, name='report_incident_active'),
    path('report_incident_deactive/', views.report_incident_deactive, name='report_incident_deactive'),

]  