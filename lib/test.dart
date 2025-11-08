import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final FocusNode _focusNode = FocusNode();
  String _barcodeBuffer = '';
  String _statusMessage = '';

  // Store scanned products
  List<Map<String, dynamic>> _scannedProducts = [];

  // Replace with your API base URL
  final String apiBaseUrl = 'http://127.0.0.1:8000/api/products/barcode-search';
  // Replace with actual stored token
  final String jwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzYyNjg2MTI1LCJpYXQiOjE3NjI1OTk3MjUsImp0aSI6ImRiNjAzMmFjOWFkOTQ2NzRiNTE5Njk5OGI0ZWI0OTMzIiwidXNlcl9pZCI6IjIifQ.LJv3l53GjkdDWHKT-YPiCpuNQfBK8NorsWN56WirY8s";

  @override
  void initState() {
    super.initState();
    // Focus the RawKeyboardListener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final keyLabel = event.character ?? '';

      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_barcodeBuffer.isNotEmpty) {
          String code = _barcodeBuffer;
          _barcodeBuffer = '';
          _fetchProduct(code);
        }
      } else if (keyLabel.isNotEmpty && keyLabel != '\n' && keyLabel != '\r') {
        _barcodeBuffer += keyLabel;
      }
    }
  }

  Future<void> _fetchProduct(String sku) async {
    setState(() {
      _statusMessage = 'Searching...';
    });

    final url = Uri.parse('$apiBaseUrl/?sku=$sku');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      });

      print(url);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final product = jsonResponse['data'];

          // Check if product already scanned
          final index = _scannedProducts.indexWhere((p) => p['sku'] == product['sku']);
          if (index >= 0) {
            // Increase quantity
            setState(() {
              _scannedProducts[index]['quantity'] += 1;
            });
          } else {
            setState(() {
              _scannedProducts.add({
                'sku': product['sku'],
                'name': product['name'],
                'price': product['selling_price'],
                'stock_qty': product['stock_qty'],
                'category': product['category_info']?['name'] ?? '',
                'brand': product['brand_info']?['name'] ?? '',
                'image': product['image'],
                'stock_status': product['stock_status_display'],
                'quantity': 1, // start with 1
              });
            });
          }

          setState(() {
            _statusMessage = 'Product added';
          });
        } else {
          setState(() {
            _statusMessage = jsonResponse['message'] ?? 'Product not found';
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _statusMessage = 'Product not found';
        });
      } else {
        setState(() {
          _statusMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Network error';
      });
    }
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: product['image'] != null
            ? Image.network(
          product['image'],
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        )
            : const Icon(Icons.image_not_supported),
        title: Text(product['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKU: ${product['sku']}'),
            Text('Category: ${product['category']}'),
            Text('Brand: ${product['brand']}'),
            Text('Stock: ${product['stock_qty']} (${product['stock_status']})'),
          ],
        ),
        trailing: Text('Qty: ${product['quantity']}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Dotmax DT-660L Barcode Scanner'),
        backgroundColor: Colors.blue,
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: _handleKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue),
                  const SizedBox(height: 10),
                  const Text(
                    'Scan a barcode...',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  if (_statusMessage.isNotEmpty)
                    Text(
                      _statusMessage,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: _scannedProducts.isNotEmpty
                  ? ListView.builder(
                itemCount: _scannedProducts.length,
                itemBuilder: (context, index) {
                  final product = _scannedProducts[index];
                  return _buildProductItem(product);
                },
              )
                  : const Center(
                child: Text(
                  'No products scanned yet.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
