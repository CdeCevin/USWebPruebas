# Pasos para levantar la aplicación

1.	Cree un entorno virtual y ejecute el siguiente comando pip install -r requirements.txt
2.	Cree una base de datos desde la consola de postgreeSQL
3.	Colóquese en la raíz del sistema y ejecute el siguiente comando cp settings.txt urban/settings.py
4.	Colóquese en la raíz del sistema y ejecute el siguiente comando cp urls.txt  urban/urls.py
5.	Configure el archivo settings.py de acuerdo con los parámetros entregados por el administrador del sistema.
6.	Ejecute el siguiente comando python manage.py mekemigrations
7.	Ejecute el siguiente comando python manage.py migrate
8.  Crearemos el superusuario de la aplicación con el comando python manage.py createsuperuser
8.	Ejecute la consola de su base de datos, una vez en ella active la base de datos agregada para la        aplicación, una vez seleccionada la base de datos ejecute las siguientes consultas SQL.

    INSERT INTO auth_group VALUES(1,'Admin');
    INSERT INTO auth_group VALUES(2,'Territorial');    
    INSERT INTO auth_group VALUES(3,'Departamento');  
    INSERT INTO auth_group VALUES(4,'Dirección');      
    INSERT INTO auth_group VALUES(5,'Cuadrilla'); 
    INSERT INTO auth_group VALUES(99,'Maps');  
    INSERT INTO registration_profile VALUES(0,'default','default',1,1);
    
    INSERT INTO administrator_config VALUES(1,'nombre municipalidad',1,'2024-01-01','2024-01-01','url_keppler','url_base');
    INSERT INTO management_management VALUES(0,'default','default','default','default','2024-01-01','2024-01-01',1);    
    INSERT INTO department_deparment VALUES(0,'default','default','2024-01-01','2024-01-01',1,0,'default','default');    
    INSERT INTO incident_incident VALUES(0,'default','default','2024-01-01','2024-01-01',1,0,0); 
    INSERT INTO brigade_brigade VALUES(0,'default','2024-01-01','2024-01-01',0);
# Tipos de flujo 
    1 => Flujo Depatamentos
    2 => Flujo Direcciones
# Grupos de usuario
    1 => Admin
    2 => Territorial
    3 => Departamento
    4 => Dirección
    5 => Cuadrilla

# Para crear un vista use la siguiente plantilla para el backend
@login_required
def nombreapp_functionname(request):
    session = int(check_profile_admin(request))
    if session == 0:
        messages.add_message(request, messages.INFO, 'Intenta ingresar a una area para la que no tiene permisos')
        return redirect('logout')
    flow = type_flow(request)
    template_name = 'nombreapp/nombreapp_functionname.html'    
    return render(request, template_name, {'profiles': profiles,'username': request.user.username,'flow':flow})

# Estados solicitudes
Inciada -> estado inicial al momento de crear, en este punto la puede ver el territorial y los usarios departamento / director, estos podrán derivarla
Derivada -> estado que puede generar tanto un usuario departamento como uno direccion, se genera desde el estado iniciado, asocia un registro de derivación y un usuario resolutor
Proceso -> Estado que solo se puede generar si la solicitud esta derivada, es responsabilidad del usuario cuadrilla
Finalizada -> Estado que solo se puede generar del perfil cuadrilla
Cancelada -> estado que se obtiene cuando un director o un departamento cancela una solicitud recien creada