import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'CALCULADORA'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String botones;
  String display;
  bool isDisplayDisable;
  String historial;
  String ultimoBotonPresionado;

  @override
  void initState() {
    botones = '789x456/123+.0-=';
    display = '0';
    historial = '';
    ultimoBotonPresionado = '';
    isDisplayDisable = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        historial,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 25,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: Text(
                        display,
                        style: TextStyle(
                          color:
                              isDisplayDisable ? Colors.black54 : Colors.black,
                          fontSize: display.length >= 8 ? 50 : 90,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: FlatButton(
                    child: Container(
                      height: 50,
                      child: Center(
                        child: Text(
                          'C',
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.blue,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      isDisplayDisable = false;
                      setState(() {
                        historial = '';
                        display = '0';
                        ultimoBotonPresionado = '';
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                  child: FlatButton(
                    child: Container(
                      height: 50,
                      child: Icon(
                        Icons.backspace,
                        color: Colors.blue,
                        size: 35,
                      ),
                    ),
                    onPressed: () {
                      if (!isDisplayDisable) {
                        if (display.length > 1)
                          setState(() {
                            display = display.substring(0, display.length - 1);
                          });
                        else
                          setState(() {
                            display = '0';
                          });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8.0),
              child: Container(
                height: 245,
                child: areaBotones(),
              ),
            ),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget areaBotones() {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
      ),
      itemCount: botones.length,
      itemBuilder: (context, index) {
        String botonPresionado = botones[index];
        return FlatButton(
          child: Text(
            botonPresionado,
            style: TextStyle(fontSize: 38),
          ),
          onPressed: () {
            if (display != 'Syntax Error') evaluarExpresion(botonPresionado);
          },
        );
      },
    );
  }

  void evaluarExpresion(String botonPresionado) {
    bool isNumeric(String s) {
      if (s == null) {
        return false;
      }
      return double.parse(s, (e) => null) != null;
    }

    if (isNumeric(botonPresionado) || botonPresionado == '.') {
      if (!isDisplayDisable) {
        setState(() {
          if (display == '0' && botonPresionado != ".") display = '';
          if (display.contains('.') && botonPresionado == '.') 
            return;
          display += botonPresionado;
        });
      }
    } else if (botonPresionado == '=') {
      if (ultimoBotonPresionado == '=') return;
      String ecuacion = historial + display;
      var resultado;
      ecuacion = ecuacion.replaceAll('x', '*');
      isDisplayDisable = true;
      setState(() {
        try {
          Parser p = Parser();
          Expression exp = p.parse(ecuacion);
          ContextModel cm = ContextModel();
          resultado = exp.evaluate(EvaluationType.REAL, cm);
          historial += display; //display + ' = ';
          display = resultado % 1 == 0
              ? resultado.round().toString()
              : resultado.toStringAsFixed(3);
        } catch (e) {
          display = "Syntax Error";
        }
      });
    } else {
      setState(() {
        if (isDisplayDisable)
          historial = display + ' ' + botonPresionado + ' ';
        else if (!isNumeric(ultimoBotonPresionado) &&
            ultimoBotonPresionado != '' && ultimoBotonPresionado != '.') {
          historial = historial.substring(0, historial.length - 2) +
              botonPresionado +
              ' ';
        } else
          historial += display + ' ' + botonPresionado + ' ';

        display = '0';

        // OTRA MANERA DE MOSTRAR EL HISTORIAL EN TIEMPO REAL
        /*if (isNumeric(historial[historial.length-1])) {
          historial += '${botonPresionado}0';
        } else
          historial =
              historial.substring(0, historial.length - 1) + botonPresionado + '0';*/
      });
      isDisplayDisable = false;
    }
    ultimoBotonPresionado = botonPresionado;
  }
}
