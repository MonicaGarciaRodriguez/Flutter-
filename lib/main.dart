//Mónica García Rodríguez

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title:
            'Proyecto Flutter 2ª EVA - Mónica García Rodríguez - Mis Plantas',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 2, 54, 35)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

//clase planta con dos propiedades nombre y tipo
class Planta {
  String nombre;
  String tipo;

  Planta({required this.nombre, required this.tipo});
}

class MyAppState extends ChangeNotifier {
  //widget que notifica los cambios

  var current = Planta(nombre: 'Rosa', tipo: 'Ornamental');
  var history = <Planta>[];
  GlobalKey? historyListKey;
  var i = 0;

  var listaPersonalizada = [
    Planta(nombre: 'Rosa', tipo: 'Ornamental'),
    Planta(nombre: 'Lirio', tipo: 'Blanco'),
    Planta(nombre: 'Tomate', tipo: 'Vegetal'),
  ];
  //boton siguiente para que salga con animacion
  void getNext() {
    if (listaPersonalizada.isNotEmpty) {
      current = listaPersonalizada[i];
      history.insert(0, current);
      var animatedList = historyListKey?.currentState as AnimatedListState?;
      animatedList?.insertItem(0);
      notifyListeners();
    }
    i++;
  }

  void anyadirElemento(String nombre, String tipo) {
    //se crea una nueva instancia de planta
    var nuevaPlanta = Planta(nombre: nombre, tipo: tipo);

    // Añadir una nueva planta a la lista
    if (nombre.isNotEmpty) {
      listaPersonalizada.add(nuevaPlanta);
    }

    notifyListeners();
  }

  //borrar elementos del listado
  void borrarElemento(int index) {
    listaPersonalizada.removeAt(index);
    notifyListeners();
  }

  var favoritas = <Planta>[];

  void toggleFavorite([Planta? planta]) {
    planta = planta ?? current;
    if (favoritas.contains(planta)) {
      favoritas.remove(planta);
    } else {
      favoritas.add(planta);
    }
    notifyListeners();
  }

  //borrar de la lista de favoritos
  void removeFavorite(Planta planta) {
    favoritas.remove(planta);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = PaginaPrincipal();
        break;
      case 1:
        page = PaginaLista();
        break;
      case 2:
        page = PaginaFavorita();
        break;
      default:
        throw UnimplementedError('No existe $selectedIndex');
    }
    var mainArea = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/fondo.jpg'),
            fit: BoxFit.cover,
            //ajustar la opacidad de la foto de fondo
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.4), BlendMode.dstATop)),
      ),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      //widget de nivel superior
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Color.fromARGB(255, 2, 54, 35),
        title: Text(
          "Proyecto Flutter 2ª EVA - Mónica García Rodríguez - Mis Plantas",
          style: TextStyle(
            fontSize: 40,
            color: Color.fromARGB(255, 240, 245, 243),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            //constrains para moviles
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Inicio',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.list),
                        label: 'Lista Plantas',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Plantas Favoritas',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Inicio'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.list),
                        label: Text('Lista Plantas'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favoritos'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

//pagina de inicio para ver el listado y añadir a favoritos
class PaginaPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var pair = appState.current;
    IconData icon;
    if (appState.favoritas.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(height: 10),
          BigCard(
            Planta: appState.current,
            pair: pair,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              //agregamos botones en la parte inferior de column
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Me gusta'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Siguiente'),
              ),
            ],
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

//clase para ver el listado dentro de card
class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
    required Planta,
  }) : super(key: key);

  final Planta pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  pair.nombre,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '  ',
                  style: style.copyWith(fontWeight: FontWeight.normal),
                ),
                Text(
                  pair.tipo,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//pagina de favoritos para consultar y boton de borrado de cada elemento
class PaginaFavorita extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
    );
    if (appState.favoritas.isEmpty) {
      return Center(
        child: Text(('OHHH!!! No tienes favoritos.'),
            style: style.copyWith(fontWeight: FontWeight.bold)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
              ('Lista favoritos:  '
                  '${appState.favoritas.length} planta'),
              style: style.copyWith(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var pair in appState.favoritas)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_rounded, semanticLabel: 'Borrar'),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.removeFavorite(pair);
                    },
                  ),
                  title: Text(
                    pair.nombre,
                    semanticsLabel: pair.tipo,
                    style: style.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey();
  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favoritas.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.nombre,
                  semanticsLabel: pair.tipo,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//pagina de listado para añadir y borrar cada elemento
class PaginaLista extends StatelessWidget {
  final TextEditingController _controladornombre = TextEditingController();
  final TextEditingController _controladortipo = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    var colorScheme = Theme.of(context).colorScheme;
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
    );
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(2),
            itemCount: appState.listaPersonalizada.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(appState.listaPersonalizada[index].nombre),
                subtitle: Text(appState.listaPersonalizada[index].tipo),
                titleTextStyle: style.copyWith(fontWeight: FontWeight.bold),
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  //muestra al principio un circulo con la 1ª vocal del nombre
                  child: Text(
                      appState.listaPersonalizada[index].nombre.substring(0, 1),
                      style: TextStyle(color: Colors.white)),
                ),
                trailing: IconButton(
                  //icono al final para poder borrar
                  icon: const Icon(Icons.delete_rounded),
                  tooltip: "Borrar",
                  onPressed: () {
                    appState.borrarElemento(index);
                  },
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          ),
        ),

        //fomulario para añadir elementos
        Column(
          children: [
            TextFormField(
              controller: _controladornombre,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Nombre: ',
                labelStyle: TextStyle(
                    color: Color.fromARGB(255, 2, 54, 35),
                    fontWeight: FontWeight.normal),
              ),
            ),
            TextFormField(
              controller: _controladortipo,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Tipo: ',
                labelStyle: TextStyle(
                    color: Color.fromARGB(255, 2, 54, 35),
                    fontWeight: FontWeight.normal),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                appState.anyadirElemento(
                    _controladornombre.text, _controladortipo.text);
                _controladornombre.clear();
                _controladortipo.clear();
              },
              child: Text(
                'Añadir',
                style: style.copyWith(fontSize: 30),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ],
    );
  }
}
