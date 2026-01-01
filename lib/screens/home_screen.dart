import 'package:flutter/material.dart';
import '../models/lost_item.dart';
import '../services/api_service.dart';
import 'add_items_screen.dart';
import 'edit_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LostItem> _items = [];
  List<LostItem> _filteredItems = [];
  bool _isLoading = true;
  String _errorMessage = '';


  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'All';
  String _selectedCategoryFilter = 'All';

  final List<String> _statusFilters = ['All', 'Lost', 'Found'];
  final List<String> _categoryFilters = ['All', 'Electronics', 'Documents', 'Accessories', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final items = await ApiService.fetchItems();
      setState(() {
        _items = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load items: $e';
        _isLoading = false;
      });
    }
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) {
        final matchesSearch = query.isEmpty ||
            item.title.toLowerCase().contains(query) ||
            item.location.toLowerCase().contains(query) ||
            (item.description?.toLowerCase().contains(query) ?? false);

        final matchesStatus = _selectedStatusFilter == 'All' ||
            item.status == _selectedStatusFilter;

        final matchesCategory = _selectedCategoryFilter == 'All' ||
            item.category == _selectedCategoryFilter;

        return matchesSearch && matchesStatus && matchesCategory;
      }).toList();
    });
  }

  void _applyFilters() {
    _performSearch();
  }

  void _clearFilters() {
    _searchController.clear();
    _selectedStatusFilter = 'All';
    _selectedCategoryFilter = 'All';
    _performSearch();
  }

  Future<void> _refreshItems() async {
    await _loadItems();
  }

  Future<void> _markAsFound(LostItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Found'),
        content: Text('Mark "${item.title}" as found?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark as Found'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await ApiService.updateItemStatus(
        itemId: item.itemId,
        status: 'Found',
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Success!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed. Try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _markAsLost(LostItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Lost'),
        content: Text('Mark "${item.title}" as lost?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark as Lost'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await ApiService.updateItemStatus(
        itemId: item.itemId,
        status: 'Lost',
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Success!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed. Try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(LostItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await ApiService.deleteItem(item.itemId);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Item deleted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete item.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showItemMenu(LostItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Item'),
                onTap: () {
                  Navigator.pop(context);
                  _editItem(item);
                },
              ),
              if (item.status == 'Lost')
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Mark as Found'),
                  onTap: () {
                    Navigator.pop(context);
                    _markAsFound(item);
                  },
                ),
              if (item.status == 'Found')
                ListTile(
                  leading: const Icon(Icons.search_off, color: Colors.orange),
                  title: const Text('Mark as Lost'),
                  onTap: () {
                    Navigator.pop(context);
                    _markAsLost(item);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Item'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteItem(item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editItem(LostItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemScreen(item: item),
      ),
    );

    if (result == true) {
      _loadItems();
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search items...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _performSearch();
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Status Filter
          FilterChip(
            label: Text(_selectedStatusFilter),
            selected: _selectedStatusFilter != 'All',
            onSelected: (selected) {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _statusFilters.map((status) {
                        return ListTile(
                          title: Text(status),
                          trailing: _selectedStatusFilter == status
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedStatusFilter = status;
                            });
                            Navigator.pop(context);
                            _applyFilters();
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),

          // Category Filter
          FilterChip(
            label: Text(_selectedCategoryFilter),
            selected: _selectedCategoryFilter != 'All',
            onSelected: (selected) {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _categoryFilters.map((category) {
                        return ListTile(
                          title: Text(category),
                          trailing: _selectedCategoryFilter == category
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedCategoryFilter = category;
                            });
                            Navigator.pop(context);
                            _applyFilters();
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),

          // Clear Filters
          if (_selectedStatusFilter != 'All' || _selectedCategoryFilter != 'All' || _searchController.text.isNotEmpty)
            ActionChip(
              label: const Text('Clear All'),
              avatar: const Icon(Icons.clear_all, size: 18),
              onPressed: _clearFilters,
            ),
        ],
      ),
    );
  }

  Widget _buildResultsInfo() {
    if (_filteredItems.isEmpty && !_isLoading && _errorMessage.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        _filteredItems.isEmpty && !_isLoading && _errorMessage.isEmpty
            ? 'No items found'
            : 'Showing ${_filteredItems.length} of ${_items.length} items',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadItems,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildResultsInfo(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );

          if (result == true) {
            _loadItems();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading items...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadItems,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No items found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty ||
                  _selectedStatusFilter != 'All' ||
                  _selectedCategoryFilter != 'All'
                  ? 'Try changing your search or filters'
                  : 'Add a lost or found item to get started',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_searchController.text.isNotEmpty ||
                _selectedStatusFilter != 'All' ||
                _selectedCategoryFilter != 'All')
              ElevatedButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshItems,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildItemCard(LostItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showItemMenu(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.status == 'Lost'
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: item.status == 'Lost'
                            ? Colors.red.withOpacity(0.3)
                            : Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.status == 'Lost' ? Icons.search_off : Icons.check_circle,
                          size: 14,
                          color: item.status == 'Lost' ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: item.status == 'Lost' ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.blueGrey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.location,
                      style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.blueGrey[600]),
                  const SizedBox(width: 8),
                  Text(
                    item.category,
                    style: TextStyle(
                      color: Colors.blueGrey[700],
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ID: ${item.itemId}',
                      style: TextStyle(
                        color: Colors.blueGrey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  item.description!,
                  style: TextStyle(
                    color: Colors.blueGrey[600],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _editItem(item),
                    tooltip: 'Edit',
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: Icon(
                      item.status == 'Lost' ? Icons.check_circle : Icons.search_off,
                      size: 20,
                    ),
                    onPressed: () => item.status == 'Lost'
                        ? _markAsFound(item)
                        : _markAsLost(item),
                    tooltip: item.status == 'Lost' ? 'Mark as Found' : 'Mark as Lost',
                    color: item.status == 'Lost' ? Colors.green : Colors.orange,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _deleteItem(item),
                    tooltip: 'Delete',
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}