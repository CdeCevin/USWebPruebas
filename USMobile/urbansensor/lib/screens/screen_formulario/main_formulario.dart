import 'package:flutter/material.dart';
import 'package:urbansensor/widgets/appbar_generica.dart';
import 'package:urbansensor/widgets/barranavegacion.dart';
import 'package:urbansensor/widgets/boton_generico.dart';
import 'package:urbansensor/screens/enviadas_plantilla/encuestas_enviadas.dart';
import 'package:urbansensor/screens/home_tipo_plantilla/home_tipo_plantilla.dart';
import 'package:urbansensor/widgets/boton_subir_audio.dart';
import 'package:urbansensor/widgets/input_formulario.dart';
import 'package:urbansensor/widgets/boton_subir_foto.dart';
import 'package:urbansensor/widgets/boton_mapa.dart';
import 'package:urbansensor/widgets/boton_modal_mapa.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urbansensor/endpoints/encuestas_service.dart';
import 'package:urbansensor/widgets/location_service_form.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:urbansensor/widgets/mapa_pre.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:urbansensor/helpers/offline_helper.dart';
import 'package:urbansensor/helpers/database_helper.dart';
import 'package:urbansensor/config/config.dart';

class PaginaFormulario extends StatefulWidget {
  final String? verEncuesta;

  const PaginaFormulario({Key? key, this.verEncuesta}) : super(key: key);

  @override
  State<PaginaFormulario> createState() => _PaginaFormularioState();
}

class _PaginaFormularioState extends State<PaginaFormulario> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> camposDinamicos = [];
  List<String> todosLosCampos = [];
  List<TextEditingController> controllers = [];
  bool mostrarSubirFoto = false;
  bool mostrarSubirVideo = false;
  bool mostrarSubirAudio = false;
  bool datosCargados = false;
  List<XFile> _files = [];
  File? incidenceAudio;
  final ImagePicker _picker = ImagePicker();
  String? selectedPriority;
  LatLng? selectedLocation;
  Map<String, int> fieldIds = {}; // Mapa para guardar los field_ids

  TextEditingController calleController = TextEditingController();
  TextEditingController numeroController = TextEditingController();

  bool hasInternet = true; // Variable para almacenar el estado de la conexión

  String? audioFilePath;
  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _listenForConnectionChanges();
    _cargarDetallesEncuesta();
  }

  Future<void> _checkInternetConnection() async {
    hasInternet = await InternetConnectionChecker().hasConnection;
    setState(() {}); // Actualizar la interfaz de usuario si es necesariO
  }

  void _listenForConnectionChanges() {
    InternetConnectionChecker().onStatusChange.listen((status) {
      final connected = status == InternetConnectionStatus.connected;
      setState(() {
        hasInternet = connected;
      });
    });
  }

  Future<void> _cargarDetallesEncuesta() async {
    final String verEncuesta = widget.verEncuesta ?? "";
    final hasInternet = await InternetConnectionChecker().hasConnection;

    String? encuestaId;

    if (hasInternet) {
      // Si hay conexión a Internet, obtenemos el ID desde la URL
      encuestaId = _obtenerEncuestaId(verEncuesta);
    } else {
      // Convertir verEncuesta a int
      int encuestaIdInt =
          int.tryParse(verEncuesta) ??
          0; // Usa 0 como valor por defecto si no se puede convertir
      encuestaId = await fetchEncuestaIdFromLocalDatabase(encuestaIdInt);
    }

    if (encuestaId != null) {
      Map<String, dynamic>? detallesEncuesta;
      if (hasInternet) {
        detallesEncuesta = await fetchEncuestaDetalles(encuestaId);
      } else {
        detallesEncuesta = await fetchEncuestaDetallesLocal(encuestaId);
      }

      if (detallesEncuesta != null) {
        // Obtener los campos estándar y los campos nuevos/personalizados
        final pollFieldsStandard = List<String>.from(
          detallesEncuesta['poll_data']['poll_fields_standard'].map(
            (field) => field.toString(),
          ),
        );
        final pollFieldsOther = List<String>.from(
          (detallesEncuesta['poll_data']['poll_fields_other'] ?? []).map(
            (field) => field.toString(),
          ),
        );

        // Combinar ambos tipos de campos en una sola lista
        final allPollFields = [...pollFieldsStandard, ...pollFieldsOther];

        print('Campos recibidos: $allPollFields');

        final mostrarSubirFotoDesdeEncuesta =
            allPollFields.contains('Imagen') || allPollFields.contains('Video');
        final mostrarSubirAudioDesdeEncuesta = allPollFields.contains('Audio');

        setState(() {
          camposDinamicos =
              allPollFields
                  .where(
                    (campo) =>
                        campo != 'Imagen' &&
                        campo != 'Audio' &&
                        campo != 'Video',
                  )
                  .toList();

          mostrarSubirFoto = mostrarSubirFotoDesdeEncuesta;
          mostrarSubirAudio = mostrarSubirAudioDesdeEncuesta;

          todosLosCampos = allPollFields.toList();

          controllers = List.generate(
            camposDinamicos.length,
            (index) => TextEditingController(),
          );
          datosCargados = true;
        });
      }
    } else {
      print('No se pudo obtener el ID de la encuesta.');
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onFilesChanged(List<XFile> files) {
    setState(() {
      _files.clear();
      _files.addAll(files);
    });
  }

  void _pickFiles(bool isImage, bool multiSelect) async {
    List<XFile> files = [];
    if (isImage && multiSelect) {
      List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        files.addAll(pickedFiles);
      }
    } else if (isImage) {
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        files.add(image);
      }
    } else {
      XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        files.add(video);
      }
    }
    files.removeWhere(
      (file) => _files.any((existingFile) => existingFile.path == file.path),
    );

    setState(() {
      _files.addAll(files);
    });
  }

  bool validarEmail(String email) {
    if (email.isEmpty) return true;
    final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
  }

  bool validarTelefonoChileno(String telefono) {
    if (telefono.isEmpty) return true;
    final RegExp telefonoRegExp = RegExp(r'^9\d{8}$');
    return telefonoRegExp.hasMatch(telefono);
  }

  bool _isLoading = false;
  void enviarFormulario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String verEncuesta = widget.verEncuesta ?? "";
    String? encuestaId;

    // Verificar la conectividad
    final hasInternet = await InternetConnectionChecker().hasConnection;

    if (hasInternet) {
      encuestaId = _obtenerEncuestaId(verEncuesta);
    } else {
      int encuestaIdInt = int.tryParse(verEncuesta) ?? 0;
      encuestaId = await fetchEncuestaIdFromLocalDatabase(encuestaIdInt);
    }

    if (encuestaId == null) {
      print('No se pudo obtener el ID de la encuesta.');
      return;
    }

    String? nameNeighbor;
    String? rutNeighbor;
    String? mailNeighbor;
    String? phoneNeighbor;
    String? incidencePriority = selectedPriority ?? "";
    String? incidenceDescription;
    double? incidenceLatitud;
    double? incidenceLongitud;

    String? calle = calleController.text;
    String? numero = numeroController.text;
    String? comuna = defaultComuna;

    if (selectedLocation != null) {
      incidenceLatitud = selectedLocation!.latitude;
      incidenceLongitud = selectedLocation!.longitude;
    }

    // Crear un mapa de respuestas dinámicas
    Map<int, String> respuestas = {};
    Map<String, String> respuestas_onl = {};

    for (int i = 0; i < camposDinamicos.length; i++) {
      String campo = camposDinamicos[i];
      String valor = controllers[i].text;
      if (campo != 'Descripcion' &&
          campo != 'Latitud' &&
          campo != 'Longitud' &&
          campo != 'Prioridad' &&
          campo != 'Correo Vecino' &&
          campo != 'Nombre Vecino' &&
          campo != 'Teléfono Vecino' &&
          campo != 'RUT' &&
          campo != 'Imagen' &&
          campo != 'Video' &&
          campo != 'Audio') {
        respuestas_onl[campo] = valor;
      }
      // Validar campos según su tipo
      if (campo == 'Correo Vecino') {
        if (!validarEmail(valor)) {
          _mostrarSnackBar(
            'Correo electrónico inválido. Por favor, ingrese un correo válido.',
          );
          return;
        } else {
          mailNeighbor = valor;
        }
      } else if (campo == 'Nombre Vecino') {
        nameNeighbor = valor;
      } else if (campo == 'Teléfono Vecino') {
        if (!validarTelefonoChileno(valor)) {
          _mostrarSnackBar(
            'Teléfono inválido. Debe comenzar con un 9 y tener 9 dígitos.',
          );
          return;
        } else {
          phoneNeighbor = valor;
        }
      } else if (campo == 'RUT') {
        if (!validarRut(valor)) {
          _mostrarSnackBar('RUT inválido. Por favor, ingrese un RUT válido.');
          return;
        } else {
          rutNeighbor = valor;
        }
      } else if (campo == 'Descripcion') {
        incidenceDescription = valor;
      }

      // Obtener el field_id correspondiente al campo actual
      int fieldId = await obtenerFieldIdPorCampo(campo, int.parse(encuestaId));

      // Imprimir para depurar fieldId y valor
      print('Campo: $campo, Valor: $valor, Field ID obtenido: $fieldId');

      // Asegurarse de que el fieldId sea válido
      if (fieldId != -1) {
        respuestas[fieldId] = valor; // Usar fieldId como clave en el mapa
        print(
          'Guardada respuesta: field_id = $fieldId, respuesta = $valor',
        ); // Imprimir el field_id y la respuesta
      } else {
        print('Field ID no encontrado para el campo: $campo');
      }
    }

    List<File> incidenceImages = [];
    File? incidenceVideo;
    File? incidenceAudio;

    // Preparar archivos multimedia
    for (var file in _files) {
      if (file.path.endsWith('.mp4')) {
        incidenceVideo = File(file.path);
      } else {
        incidenceImages.add(File(file.path));
      }
    }
    if (audioFilePath != null) {
      //final audioFilePath ='/data/user/0/com.example.urbansensor/app_flutter/audio.m4a';
      final audioFile = File(audioFilePath!);
      if (await audioFile.exists()) {
        incidenceAudio = audioFile;
      } else {
        incidenceAudio = null;
        print('Archivo de audio no encontrado: $audioFilePath');
      }
    }
    if (hasInternet) {
      // Guardado online
      setState(() {
        _isLoading = true; // Mostrar el indicador de carga
      });
      Map<String, dynamic> response = await guardarEncuesta(
        pollId: int.parse(encuestaId),
        nameNeighbor: nameNeighbor,
        rutNeighbor: rutNeighbor,
        mailNeighbor: mailNeighbor,
        phoneNeighbor: phoneNeighbor,
        incidencePriority: incidencePriority,
        incidenceDescription: incidenceDescription,
        incidenceLatitud: incidenceLatitud,
        incidenceLongitud: incidenceLongitud,
        incidenceImages: incidenceImages,
        incidenceVideo: incidenceVideo,
        incidenceAudio: incidenceAudio,
        respuestas: respuestas_onl,
      );
      if (audioFilePath != null) {
        final audioFile = File(audioFilePath!);
        if (await audioFile.exists()) {
          await audioFile.delete();
        }
      }
      setState(() {
        _isLoading = false; // Mostrar el indicador de carga
      });
      if (response['Msj'] == 'Encuesta creada') {
        _mostrarSnackBar('¡Solicitud creada con éxito!', success: true);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Enviadas()),
        );
      } else {
        _mostrarSnackBar('Error al guardar la solicitud', success: true);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Encuestas()),
        );
      }
    } else {
      // Guardado offline
      await guardarEncuestaOffline(
        pollId: int.parse(encuestaId),
        calle: calle,
        numero: numero,
        comuna: comuna,
        incidencePriority: incidencePriority,
        incidenceLatitud: incidenceLatitud,
        incidenceLongitud: incidenceLongitud,
        incidenceImages: incidenceImages,
        incidenceVideo: incidenceVideo,
        incidenceAudio: incidenceAudio,
        respuestas: respuestas,
      );

      print(
        'Mapa de respuestas guardado: $respuestas',
      ); // Imprimir el mapa de respuestas completo
      _mostrarSnackBar('¡Encuesta guardada localmente!', success: true);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Enviadas()),
      );
    }
  }

  Future<int> obtenerFieldIdPorCampo(String campo, int pollId) async {
    Map<int, String> fieldIds = await _obtenerFieldIdsPorPollId(pollId);
    print(
      'Field IDs obtenidos para pollId $pollId: $fieldIds',
    ); // Imprimir el mapa obtenido
    return fieldIds.entries
        .firstWhere(
          (element) => element.value == campo,
          orElse: () => MapEntry(-1, ''),
        )
        .key;
  }

  Future<Map<int, String>> _obtenerFieldIdsPorPollId(int pollId) async {
    final db =
        await DatabaseHelper
            .instance
            .database; // Asumiendo que tienes una función para obtener tu instancia de DB
    final List<Map<String, dynamic>> maps = await db.query(
      'fields',
      where: 'poll_id = ?',
      whereArgs: [pollId],
    );

    // Convertir los resultados en un mapa de {field_id: nombre}
    Map<int, String> fieldIds = {};
    for (var map in maps) {
      fieldIds[map['id']] = map['label'];
    }
    print(fieldIds);

    return fieldIds;
  }

  // Función para mostrar SnackBar
  void _mostrarSnackBar(String mensaje, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8.0),
            Text(mensaje, style: TextStyle(color: Colors.black)),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.15;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double mapHeight = screenHeight * 0.12;
    final double mapWidth = screenWidth * 0.85;

    if (!datosCargados) {
      return Scaffold(
        appBar: MyAppBar(title: 'FORMULARIOS', appBarHeight: appBarHeight),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: MyAppBar(title: 'FORMULARIOS', appBarHeight: appBarHeight),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 4.0),
                          Row(
                            children: [
                              Spacer(),
                              Text(
                                'Ubicación',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Center(
                            child: Container(
                              height: mapHeight,
                              width: mapWidth,
                              child: MapaPrev(
                                location: selectedLocation,
                                width: mapWidth,
                                height: mapHeight,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Center(
                            child:
                                hasInternet // Verifica si hay conexión a Internet
                                    ? BotonAbrirMapa(
                                      onPressed: () async {
                                        LatLng? location = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => MapaScreen(
                                                  selectedLocation:
                                                      selectedLocation,
                                                ),
                                          ),
                                        );

                                        if (location != null) {
                                          setState(() {
                                            selectedLocation = location;
                                          });
                                          LocationService().updateLocation(
                                            selectedLocation!,
                                          );
                                        }
                                      },
                                    )
                                    : Container(), // Si no hay conexión, no muestra el botón
                          ),
                          SizedBox(height: 8.0),
                          Center(
                            child:
                                hasInternet // Verifica si hay conexión a Internet
                                    ? LayoutBuilder(
                                      builder: (context, constraints) {
                                        double widthPercentage = 0.9;
                                        double calculatedWidth =
                                            constraints.maxWidth *
                                            widthPercentage;

                                        return Container(
                                          width: calculatedWidth,
                                          child: Center(
                                            child: StreamBuilder<String?>(
                                              stream:
                                                  LocationService()
                                                      .addressStream,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData &&
                                                    snapshot.data != null) {
                                                  return Text(
                                                    'Dirección: ${snapshot.data}',
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  );
                                                } else {
                                                  return Text(
                                                    'No se ha seleccionado una ubicación',
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    : Container(), // Si no hay conexión, no muestra el fragmento
                          ),
                          SizedBox(height: 16.0),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                camposDinamicos.length + (hasInternet ? 0 : 3),
                            itemBuilder: (context, index) {
                              if (index < camposDinamicos.length) {
                                // Mostrar campos estándar y el campo de Prioridad
                                if (camposDinamicos[index] == 'Prioridad') {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2.0,
                                    ),
                                    child: Center(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.80,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8.0,
                                              ),
                                              child: Text(
                                                'Prioridad',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                border: Border.all(
                                                  color: const Color.fromARGB(
                                                    255,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                  ),
                                              child: DropdownButtonFormField<
                                                String
                                              >(
                                                value: selectedPriority,
                                                items:
                                                    [
                                                      'Baja',
                                                      'Media',
                                                      'Alta',
                                                    ].map((String value) {
                                                      return DropdownMenuItem<
                                                        String
                                                      >(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    selectedPriority = newValue;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 13.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (camposDinamicos[index] !=
                                        'Latitud' &&
                                    camposDinamicos[index] != 'Longitud') {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2.0,
                                    ),
                                    child: Center(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.80,
                                        child: InputFormulario(
                                          title: camposDinamicos[index],
                                          hintText: '---',
                                          controller: controllers[index],
                                          validateRut:
                                              camposDinamicos[index] == 'RUT',
                                          onlyNumbers:
                                              camposDinamicos[index] ==
                                              'Teléfono Vecino',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                // Mostrar campos adicionales de dirección cuando no hay conexión
                                final extraIndex =
                                    index - camposDinamicos.length;
                                switch (extraIndex) {
                                  case 0:
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2.0,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.80,
                                          child: _buildCalleField(),
                                        ),
                                      ),
                                    );
                                  case 1:
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2.0,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.80,
                                          child: _buildNumeroField(),
                                        ),
                                      ),
                                    );
                                  case 2:
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2.0,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.80,
                                          child: _buildComunaField(),
                                        ),
                                      ),
                                    );
                                  default:
                                    return SizedBox.shrink();
                                }
                              }
                              return SizedBox.shrink();
                            },
                          ),
                          if (todosLosCampos.contains('Audio'))
                            Column(
                              children: [
                                SubirAudioButton(
                                  onAudioSelected: (audioFile, path) {
                                    setState(() {
                                      incidenceAudio = audioFile;
                                      audioFilePath = path;
                                    });
                                  },
                                ),
                              ],
                            ),
                          if (todosLosCampos.contains('Imagen') ||
                              todosLosCampos.contains('Video'))
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (todosLosCampos.contains('Imagen') ||
                                    todosLosCampos.contains('Video'))
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      SubirFoto(
                                        onFilesChanged: _onFilesChanged,
                                        camposDinamicos: todosLosCampos,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 20.0,
            left: (screenWidth - (screenWidth * 0.25)),
            child: Container(
              width: screenWidth * 0.2,
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B69AE),
                  padding: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    _isLoading
                        ? null // deshabilitado si está cargando
                        : () {
                          enviarFormulario();
                        },
                child:
                    _isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(Icons.send, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BarraNavegacion(currentIndex: 0),
    );
  }

  Widget _buildCalleField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.80,
          child: TextField(
            controller: calleController, // Vincula el controller aquí
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Calle',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // El valor se actualizará automáticamente en calleController
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNumeroField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.80,
          child: TextField(
            controller:
                numeroController, // Asegúrate de vincular el controller aquí
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Número',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // El valor se actualiza automáticamente en numeroController
            },
          ),
        ),
      ),
    );
  }

  Widget _buildComunaField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.80,
          child: TextFormField(
            initialValue: defaultComuna,
            decoration: InputDecoration(
              labelText: 'Comuna',
              border: OutlineInputBorder(),
            ),
            readOnly: true, // Impide la edición del campo
          ),
        ),
      ),
    );
  }

  String? _obtenerEncuestaId(String url) {
    print('Obteniendo id');
    final int lastIndex = url.lastIndexOf('/');
    if (lastIndex != -1) {
      final String id = url.substring(lastIndex + 1);
      print("ids: $id");
      return id;
    }
    return null;
  }
}
