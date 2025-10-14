from django.db import models
from django.utils.timezone import now
from django.contrib.auth.models import User
from incident.models import Incident
from department.models import Deparment
from brigade.models import Brigade

class Poll(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, default=0)
    incident = models.ForeignKey(Incident, on_delete=models.CASCADE)
    name = models.CharField(max_length=240, null=True, blank=True, verbose_name='Incidente', default="N/A")
    state = models.CharField(max_length=100, null=True, blank=True, verbose_name='Estado',default="Activo")
    created = models.DateTimeField(auto_now_add=True,verbose_name='Fecha Creación')
    updated = models.DateTimeField(auto_now=True,verbose_name='Fecha Actualización')
    
    class Meta:
        verbose_name = 'Encuesta'
        verbose_name_plural = 'Encuesta'
        ordering = ['name']
    
    def __str__(self):
        return self.name

class Fields(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, default=0)
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)
    name = models.CharField(max_length=240, null=True, blank=True, verbose_name='name', default="name")
    label = models.CharField(max_length=240, null=True, blank=True, verbose_name='Label', default="Label")
    placeholder = models.CharField(max_length=240, null=True, blank=True, verbose_name='Placeholder', default="placeholder")
    kind = models.CharField(max_length=240, null=True, blank=True, verbose_name='Tipo_campo', default="Tipo_campo")
    kind_field = models.CharField(max_length=240, null=True, blank=True, verbose_name='Tipo_campo', default="standard")
    state = models.CharField(max_length=100, null=True, blank=True, verbose_name='Estado',default="Activo")
    created = models.DateTimeField(auto_now_add=True,verbose_name='Fecha Creación')
    updated = models.DateTimeField(auto_now=True,verbose_name='Fecha Actualización')
    
    class Meta:
        verbose_name = 'Campo'
        verbose_name_plural = 'Campo'
        ordering = ['name']
    
    def __str__(self):
        return self.name
    

class Request(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, default=0)
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE, default=0)
    deparment = models.ForeignKey(Deparment, on_delete=models.CASCADE, default=0)
    brigade = models.ForeignKey(Brigade, on_delete=models.CASCADE, default=0)
    request_name = models.CharField(max_length=240, null=True, blank=True, verbose_name='Solicitud', default="N/A")
    request_date = models.DateField(null=True, blank=True, verbose_name='Fecha solicitud')   
    request_delivery = models.DateField(null=True, blank=True, verbose_name='Fecha derivación')
    request_accept = models.DateField(null=True, blank=True, verbose_name='Fecha aceptación')
    request_close = models.DateField(null=True, blank=True, verbose_name='Fecha cierre')
    request_finish = models.DateField(null=True, blank=True,default='2024-01-01', verbose_name='Fecha finaliza')
    request_state = models.CharField(max_length=100, null=True, blank=True, verbose_name='Estado',default="Iniciada")
    created = models.DateTimeField(auto_now_add=True,verbose_name='Fecha Creación')
    updated = models.DateTimeField(auto_now=True,verbose_name='Fecha Actualización')   
    class Meta:
        verbose_name = 'Solicitud'
        verbose_name_plural = 'Solicitudes'
        ordering = ['request_date']
    
    def __str__(self):
        return self.request_name

class RequestRecord(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, default=0)
    request = models.ForeignKey(Request, on_delete=models.CASCADE, default=0)
    request_record_kind = models.CharField(max_length=240, null=True, blank=True, verbose_name='Tipo de registro', default="N/A")
    request_record_text = models.CharField(max_length=240, null=True, blank=True, verbose_name='Registro', default="N/A")
    created = models.DateTimeField(auto_now_add=True,verbose_name='Fecha Creación')
    updated = models.DateTimeField(auto_now=True,verbose_name='Fecha Actualización')   
    class Meta:
        verbose_name = 'Registro solicitud'
        verbose_name_plural = 'Registros solicitudes'
        ordering = ['created']
    
    def __str__(self):
        return self.request_record_text
    
class RequestAnswer(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, default=0)
    request = models.ForeignKey(Request, on_delete=models.CASCADE, default=0)
    fields = models.ForeignKey(Fields, on_delete=models.CASCADE, default=0)
    request_answer_text = models.CharField(max_length=240, null=True, blank=True, verbose_name='Tipo de registro', default="N/A")
    created = models.DateTimeField(auto_now_add=True,verbose_name='Fecha Creación')
    updated = models.DateTimeField(auto_now=True,verbose_name='Fecha Actualización')   
    class Meta:
        verbose_name = 'Respuesta'
        verbose_name_plural = 'Respuestas'
        ordering = ['created']
    
    def __str__(self):
        return self.request_answer_text