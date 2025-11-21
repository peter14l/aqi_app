import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/app_colors.dart';
import '../../data/location_service.dart';
import '../../data/location_state_provider.dart';
import '../../domain/location_model.dart';

class LocationSearchDialog extends ConsumerStatefulWidget {
  const LocationSearchDialog({super.key});

  @override
  ConsumerState<LocationSearchDialog> createState() =>
      _LocationSearchDialogState();
}

class _LocationSearchDialogState extends ConsumerState<LocationSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();

  List<LocationModel> _searchResults = [];
  List<LocationModel> _recentSearches = [];
  bool _isSearching = false;
  String _errorMessage = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    try {
      // For now, we'll just clear recent searches since the method isn't implemented
      // In a real app, you would load recent searches from shared preferences
      setState(() {
        _recentSearches = [];
      });
    } catch (e) {
      // Ignore errors for now
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = '';
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final results = await _locationService.searchLocations(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to search locations';
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _selectLocation(LocationModel location) async {
    final locationState = LocationState(
      name: location.name,
      latitude: location.latitude,
      longitude: location.longitude,
      country: location.country,
    );

    try {
      // Update provider
      ref.read(locationProvider.notifier).setLocation(locationState);
      
      // Close the dialog
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayList =
        _searchController.text.trim().isEmpty
            ? _recentSearches
            : _searchResults;

    return Dialog(
      backgroundColor: AppColors.particulatesCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Search Location',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.textPrimaryDark,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search TextField
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              style: GoogleFonts.outfit(color: AppColors.textPrimaryDark),
              decoration: InputDecoration(
                hintText: 'Enter city name...',
                hintStyle: GoogleFonts.outfit(color: AppColors.textTertiary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textTertiary,
                ),
                suffixIcon:
                    _isSearching
                        ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        )
                        : null,
                filled: true,
                fillColor: AppColors.textPrimaryDark.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Error message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage,
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.red),
                ),
              ),

            // Section title
            Text(
              _searchController.text.trim().isEmpty
                  ? 'RECENT SEARCHES'
                  : 'SEARCH RESULTS',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),

            // Results list
            Expanded(
              child:
                  displayList.isEmpty
                      ? Center(
                        child: Text(
                          _searchController.text.trim().isEmpty
                              ? 'No recent searches'
                              : 'No results found',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final location = displayList[index];
                          return _buildLocationItem(location);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(LocationModel location) {
    final subtitle = [
      if (location.admin1 != null) location.admin1,
      if (location.country != null) location.country,
    ].join(', ');

    return InkWell(
      onTap: () => _selectLocation(location),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.textPrimaryDark.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _locationService.dispose();
    super.dispose();
  }
}
