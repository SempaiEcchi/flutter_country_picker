import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import 'country.dart';
import 'res/country_codes.dart';
import 'utils.dart';

class CountryListView extends StatefulWidget {
  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country> onSelect;

  /// An optional [showPhoneCode] argument can be used to show phone code.
  final bool showPhoneCode;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [countryFilter]
  final List<String>? exclude;

  /// An optional [countryFilter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [countryFilter] and [exclude]
  final List<String>? countryFilter;

  /// An optional argument for for customizing the
  /// country list bottom sheet.
  final CountryListThemeData? countryListTheme;

  const CountryListView({
    Key? key,
    required this.onSelect,
    this.exclude,
    this.countryFilter,
    this.showPhoneCode = false,
    this.countryListTheme,
  })  : assert(exclude == null || countryFilter == null,
            'Cannot provide both exclude and countryFilter'),
        super(key: key);

  @override
  _CountryListViewState createState() => _CountryListViewState();
}

class _CountryListViewState extends State<CountryListView> {
  late List<Country> _countryList;
  late List<Country> _filteredList;
  late TextEditingController _searchController;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _countryList =
        countryCodes.map((country) => Country.from(json: country)).toList();

    //Remove duplicates country if not use phone code
    if (!widget.showPhoneCode) {
      final ids = _countryList.map((e) => e.countryCode).toSet();
      _countryList.retainWhere((country) => ids.remove(country.countryCode));
    }

    if (widget.exclude != null) {
      _countryList.removeWhere(
          (element) => widget.exclude!.contains(element.countryCode));
    }
    if (widget.countryFilter != null) {
      _countryList.removeWhere(
          (element) => !widget.countryFilter!.contains(element.countryCode));
    }

    _filteredList = <Country>[];
    _filteredList.addAll(_countryList);
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardactive = MediaQuery.of(context).viewInsets.bottom > 10;
    final String searchLabel =
        CountryLocalizations.of(context)?.countryName(countryCode: 'search') ??
            'Search';

    var greyBorder = const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(50.0)),
        borderSide: BorderSide(color: Color(0xff40000000), width: 0.8));

    return Column(
      children: <Widget>[
        SizedBox(height: keyboardactive ? 60 : 30),
        Row(
          children: [
            Flexible(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                height: 48,
                child: TextField(
                  onChanged: _filterSearchResults,
                  textAlignVertical: TextAlignVertical.bottom,
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    border: greyBorder,
                    focusedBorder: greyBorder,
                    enabledBorder: greyBorder,
                    errorBorder: greyBorder,
                    disabledBorder: greyBorder,
                    hintText: searchLabel,
                  ),
                ),
              ),
            )),
          ],
        ),
        Expanded(
          child: ListView(
            children: _filteredList
                .map<Widget>((country) => _listRow(country))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _listRow(Country country) {
    final TextStyle _textStyle =
        widget.countryListTheme?.textStyle ?? _defaultTextStyle;

    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onSelect(country);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 20),
              Text(
                Utils.countryCodeToEmoji(country.countryCode),
                style: TextStyle(
                  fontSize: widget.countryListTheme?.flagSize ?? 25,
                ),
              ),
              if (widget.showPhoneCode) ...[
                const SizedBox(width: 15),
                SizedBox(
                  width: 45,
                  child: Text(
                    '+${country.phoneCode}',
                    style: _textStyle,
                  ),
                ),
                const SizedBox(width: 5),
              ] else
                const SizedBox(width: 15),
              Expanded(
                child: Text(
                  CountryLocalizations.of(context)
                          ?.countryName(countryCode: country.countryCode) ??
                      country.name,
                  style: _textStyle,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _filterSearchResults(String query) {
    List<Country> _searchResult = <Country>[];
    final CountryLocalizations? localizations =
        CountryLocalizations.of(context);

    if (query.isEmpty) {
      _searchResult.addAll(_countryList);
    } else {
      _searchResult = _countryList
          .where((c) => c.startsWith(query, localizations))
          .toList();
    }

    setState(() => _filteredList = _searchResult);
  }

  get _defaultTextStyle => const TextStyle(fontSize: 16);
}
