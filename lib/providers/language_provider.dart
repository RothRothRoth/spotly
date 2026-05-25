import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _langKey = 'selectedLanguage';
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadLanguage();
  }

  void _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_langKey) ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    _currentLanguage = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, _currentLanguage);
    notifyListeners();
  }

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? _translations['en']?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'my_profile': 'My Profile',
      'shared_spots': 'Shared Spots',
      'favorites': 'Favorites',
      'edit_profile': 'Edit Profile',
      'logout': 'Log Out',
      'settings': 'Settings',
      'about': 'About',
      'hello': 'Hello',
      'explore': 'Explore',
      'search': 'Search',
      'add_spot': 'Add Spot',
      'recent_spots': 'Recently Checked Spots',
      'no_favorites': 'No favorites yet',
      'no_spots': 'No spots shared yet',
      'title': 'Title',
      'description': 'Description',
      'save': 'Save',
      'cancel': 'Cancel',
      'welcome_title': 'Join the Spotly community today!',
      'login': 'Log In',
      'signup': 'Sign Up',
    },
    'fr': {
      'my_profile': 'Mon Profil',
      'shared_spots': 'Lieux Partagés',
      'favorites': 'Favoris',
      'edit_profile': 'Modifier le Profil',
      'logout': 'Déconnexion',
      'settings': 'Paramètres',
      'about': 'À Propos',
      'hello': 'Bonjour',
      'explore': 'Explorer',
      'search': 'Recherche',
      'add_spot': 'Ajouter un Lieu',
      'recent_spots': 'Lieux Récemment Consultés',
      'no_favorites': 'Aucun favori pour le moment',
      'no_spots': 'Aucun lieu partagé',
      'title': 'Titre',
      'description': 'Description',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'welcome_title': 'Rejoignez la communauté Spotly !',
      'login': 'Connexion',
      'signup': 'Inscription',
    },
    'es': {
      'my_profile': 'Mi Perfil',
      'shared_spots': 'Lugares Compartidos',
      'favorites': 'Favoritos',
      'edit_profile': 'Editar Perfil',
      'logout': 'Cerrar Sesión',
      'settings': 'Ajustes',
      'about': 'Acerca de',
      'hello': 'Hola',
      'explore': 'Explorar',
      'search': 'Buscar',
      'add_spot': 'Añadir Lugar',
      'recent_spots': 'Lugares Vistos Recientemente',
      'no_favorites': 'No hay favoritos aún',
      'no_spots': 'No hay lugares compartidos',
      'title': 'Título',
      'description': 'Descripción',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'welcome_title': '¡Únete a la comunidad Spotly hoy!',
      'login': 'Iniciar Sesión',
      'signup': 'Regístrate',
    },
  };
}
