import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Reservaciones',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReservationSystem(),
    );
  }
}

class Reservation {
  final String name;
  final int numberOfPeople;
  final String restaurant;
  final String timeSlot;

  Reservation(this.name, this.numberOfPeople, this.restaurant, this.timeSlot);
}

class ReservationSystem extends StatefulWidget {
  @override
  _ReservationSystemState createState() => _ReservationSystemState();
}

class _ReservationSystemState extends State<ReservationSystem> {
  final List<Reservation> _reservations = [];
  final Map<String, int> _restaurantCapacities = {
    'Ember': 3,
    'Zao': 4,
    'Grappa': 2,
    'Larimar': 3,
  };

  String _selectedRestaurant = 'Ember';
  String _selectedTimeSlot = '6-8 PM';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberOfPeopleController =
      TextEditingController();

  // Función que calcula la capacidad restante del restaurante seleccionado
  int _getRemainingCapacity() {
    final capacity = _restaurantCapacities[_selectedRestaurant] ?? 0;
    final reservedCount = _reservations
        .where((r) =>
            r.restaurant == _selectedRestaurant &&
            r.timeSlot == _selectedTimeSlot)
        .fold(0, (sum, r) => sum + r.numberOfPeople);

    return capacity - reservedCount;
  }

  void _addReservation() {
    final name = _nameController.text;
    final numberOfPeople = int.tryParse(_numberOfPeopleController.text);

    if (name.isEmpty || numberOfPeople == null || numberOfPeople <= 0) {
      return; // Show an error message in a real app
    }

    final capacity = _restaurantCapacities[_selectedRestaurant] ?? 0;
    final reservedCount = _reservations
        .where((r) =>
            r.restaurant == _selectedRestaurant &&
            r.timeSlot == _selectedTimeSlot)
        .fold(0, (sum, r) => sum + r.numberOfPeople);

    if (reservedCount + numberOfPeople > capacity) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Capacidad Excedida'),
          content: Text(
              'No hay suficiente espacio en $_selectedRestaurant para $numberOfPeople personas en el horario $_selectedTimeSlot.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _reservations.add(Reservation(
          name, numberOfPeople, _selectedRestaurant, _selectedTimeSlot));
    });

    _nameController.clear();
    _numberOfPeopleController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sistema de Reservaciones'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center( // Añadido para centrar el contenido
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: _selectedRestaurant,
                  items: _restaurantCapacities.keys.map((restaurant) {
                    return DropdownMenuItem(
                      value: restaurant,
                      child: Text(restaurant),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRestaurant = value ?? 'Ember';
                    });
                  },
                ),
                DropdownButton<String>(
                  value: _selectedTimeSlot,
                  items: ['6-8 PM', '8-10 PM'].map((timeSlot) {
                    return DropdownMenuItem(
                      value: timeSlot,
                      child: Text(timeSlot),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeSlot = value ?? '6-8 PM';
                    });
                  },
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: _numberOfPeopleController,
                  decoration: InputDecoration(labelText: 'Cantidad de personas'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                Text(
                  'Capacidad restante: ${_getRemainingCapacity()} personas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addReservation,
                      child: Text('Agregar Reservación'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showReservations,
                      child: Text('Ver Reservaciones'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showReservationsByRestaurant,
                      child: Text('Imprimir Reservaciones por Restaurante'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReservations() {
    showDialog(
      context: context,
      builder: (ctx) {
        final reservationsForTimeSlot = _reservations
            .where((r) => r.timeSlot == _selectedTimeSlot)
            .toList();

        return AlertDialog(
          title: Text('Reservaciones para $_selectedRestaurant'),
          content: SingleChildScrollView(
            child: Column(
              children: reservationsForTimeSlot
                  .map((r) => Text('${r.name}: ${r.numberOfPeople} personas'))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showReservationsByRestaurant() {
    final reservationsByRestaurant = _reservations
        .where((r) => r.restaurant == _selectedRestaurant)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Reservaciones en $_selectedRestaurant'),
          content: SingleChildScrollView(
            child: Column(
              children: reservationsByRestaurant
                  .map((r) => Text(
                      '${r.timeSlot} - ${r.name}: ${r.numberOfPeople} personas'))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
