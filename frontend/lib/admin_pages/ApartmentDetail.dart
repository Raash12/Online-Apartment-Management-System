import 'package:flutter/material.dart';

class ApartmentDetailPage extends StatelessWidget {
  final Map<String, dynamic> apartmentData;

  const ApartmentDetailPage({super.key, required this.apartmentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        foregroundColor: Colors.white, 
        title: Text(apartmentData['name'] ?? 'Apartment Detail' , ),
        backgroundColor: Colors.deepPurple,
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                apartmentData['imageUrl'] ?? '',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 120),
              ),
            ),
            const SizedBox(height: 16),
            Text('Location: ${apartmentData['location']}', style: const TextStyle(fontSize: 16)),
            Text('Rent: \$${apartmentData['rent']}', style: const TextStyle(fontSize: 16)),
            Text('Bedrooms: ${apartmentData['bedrooms']}', style: const TextStyle(fontSize: 16)),
            Text('Bathrooms: ${apartmentData['bathrooms']}', style: const TextStyle(fontSize: 16)),
            Text('Size: ${apartmentData['size']} sqft', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            const Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(apartmentData['description'] ?? '', style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
