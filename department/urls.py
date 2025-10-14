from django.urls import path
from department import views

department_patterns = [
    path('department_add', views.department_add,name="department_add"),

    path('department_list_active', views.department_list_active,name="department_list_active"),
    path('department_list_active/<page>/', views.department_list_active,name="department_list_active"),
    path('department_block/<department_id>/', views.department_block,name="department_block"),
    path('department_activate/<department_id>/', views.department_activate,name="department_activate"),
    path('department_list_deactive', views.department_list_deactive,name="department_list_deactive"),
    path('department_list_deactive/<page>/', views.department_list_deactive,name="department_list_deactive"),
    path('department_edit/<department_id>/', views.department_edit,name="department_edit"),
    path('department_edit_save/', views.department_edit_save,name="department_edit_save"),

    path('report_department_active/', views.report_department_actives, name='report_department_active'),
    path('report_department_deactive/', views.report_department_deactives, name='report_department_deactive'),
]  