from django.contrib.auth.models import User, Group
from rest_framework import serializers
from incident.models import Incident
from poll.models import Poll,Request, Fields, RequestAnswer

class IncidentSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Incident
        fields = ('id','user_id','management_id','deparment_id','name','state','created','updated')

class PollSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Poll
        fields = ('id','user_id','incident_id','name','state','created','updated')

class FieldSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Fields
        fields = ('id','user_id','poll_id','name','label','placeholder','kind','kind_field','state','created','updated')

class RequestIdSerializer(serializers.Serializer):
    id = serializers.IntegerField()

class RequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Request
        fields = '__all__'  # Esto incluye todos los campos del modelo Request


class RequestAnswerSerializer(serializers.ModelSerializer):
    class Meta:
        model = RequestAnswer
        fields = '__all__'  # Esto incluye todos los campos del modelo RequestAnswer