class NigerianCity {
  final String name;
  final String state;
  final double latitude;
  final double longitude;
  final double timezone;

  const NigerianCity({
    required this.name,
    required this.state,
    required this.latitude,
    required this.longitude,
    this.timezone = 1.0,
  });
}

const List<NigerianCity> kNigerianCities = [
  NigerianCity(name: 'Lagos', state: 'Lagos', latitude: 6.5244, longitude: 3.3792),
  NigerianCity(name: 'Abuja', state: 'FCT', latitude: 9.0765, longitude: 7.3986),
  NigerianCity(name: 'Kano', state: 'Kano', latitude: 12.0022, longitude: 8.5920),
  NigerianCity(name: 'Ibadan', state: 'Oyo', latitude: 7.3775, longitude: 3.9470),
  NigerianCity(name: 'Kaduna', state: 'Kaduna', latitude: 10.5222, longitude: 7.4383),
  NigerianCity(name: 'Zaria', state: 'Kaduna', latitude: 11.0667, longitude: 7.7000),
  NigerianCity(name: 'Port Harcourt', state: 'Rivers', latitude: 4.8156, longitude: 7.0498),
  NigerianCity(name: 'Benin City', state: 'Edo', latitude: 6.3350, longitude: 5.6037),
  NigerianCity(name: 'Maiduguri', state: 'Borno', latitude: 11.8311, longitude: 13.1511),
  NigerianCity(name: 'Zungeru', state: 'Niger', latitude: 9.7960, longitude: 6.1492),
  NigerianCity(name: 'Sokoto', state: 'Sokoto', latitude: 13.0059, longitude: 5.2476),
  NigerianCity(name: 'Oshogbo', state: 'Osun', latitude: 7.7827, longitude: 4.5418),
  NigerianCity(name: 'Ilorin', state: 'Kwara', latitude: 8.4966, longitude: 4.5421),
  NigerianCity(name: 'Jos', state: 'Plateau', latitude: 9.8965, longitude: 8.8583),
  NigerianCity(name: 'Enugu', state: 'Enugu', latitude: 6.4527, longitude: 7.5100),
  NigerianCity(name: 'Aba', state: 'Abia', latitude: 5.1066, longitude: 7.3667),
  NigerianCity(name: 'Onitsha', state: 'Anambra', latitude: 6.1667, longitude: 6.7833),
  NigerianCity(name: 'Warri', state: 'Delta', latitude: 5.5167, longitude: 5.7500),
  NigerianCity(name: 'Bauchi', state: 'Bauchi', latitude: 10.3158, longitude: 9.8442),
  NigerianCity(name: 'Gusau', state: 'Zamfara', latitude: 12.1704, longitude: 6.6640),
  NigerianCity(name: 'Yola', state: 'Adamawa', latitude: 9.2035, longitude: 12.4954),
  NigerianCity(name: 'Birnin Kebbi', state: 'Kebbi', latitude: 12.4530, longitude: 4.1997),
  NigerianCity(name: 'Dutse', state: 'Jigawa', latitude: 11.7656, longitude: 9.3430),
  NigerianCity(name: 'Damaturu', state: 'Yobe', latitude: 11.7469, longitude: 11.9606),
  NigerianCity(name: 'Jalingo', state: 'Taraba', latitude: 8.8907, longitude: 11.3614),
];
