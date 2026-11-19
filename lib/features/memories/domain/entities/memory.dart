class Memory {
  const Memory({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.location,
    this.isPersonal = false,
  });

  final String id;
  final String title;
  final String imageUrl;
  final DateTime date;
  final String location;
  final bool isPersonal;
}

abstract final class SeedMemories {
  static final List<Memory> items = [
    Memory(
      id: 'seed-1',
      title: 'Nuestro lugar favorito',
      imageUrl: 'https://images.unsplash.com/photo-1556229868-7b2d4b56b909?auto=format&fit=crop&w=900&q=84',
      date: DateTime.parse('2025-06-14T20:42:00'),
      location: 'Playa de Bolonia, Cádiz',
    ),
    Memory(
      id: 'seed-2',
      title: 'Domingo sin prisa',
      imageUrl: 'https://images.unsplash.com/photo-1490723186985-6d7672633c86?auto=format&fit=crop&w=900&q=84',
      date: DateTime.parse('2025-05-25T12:18:00'),
      location: 'El Retiro, Madrid',
    ),
    Memory(
      id: 'seed-3',
      title: 'Un día de campo',
      imageUrl: 'https://images.unsplash.com/photo-1693129551108-c1e0ab10f10e?auto=format&fit=crop&w=900&q=84',
      date: DateTime.parse('2025-04-19T17:06:00'),
      location: 'Cercedilla, Madrid',
    ),
    Memory(
      id: 'seed-4',
      title: 'Hasta que se fue el sol',
      imageUrl: 'https://images.unsplash.com/photo-1755189551092-79ae45166ce3?auto=format&fit=crop&w=900&q=84',
      date: DateTime.parse('2025-03-08T19:51:00'),
      location: 'San Vicente, Ibiza',
    ),
  ];
}
