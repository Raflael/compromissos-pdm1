# O device_calendar converte os eventos com Gson; sem esta regra o R8
# renomeia as classes no build de release e retrieveCalendars() falha.
-keep class com.builttoroam.devicecalendar.** { *; }
