import 'package:universal_html/html.dart' as html;
import 'package:js/js.dart';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;

/// Определяем внешние JavaScript функции с использованием аннотации @JS.
@JS('document.exitFullscreen')
external void exitFullscreen();

@JS('document.documentElement.requestFullscreen')
external void requestFullscreen();

/// Главная точка входа в приложение.
/// Запускает виджет [MyApp], который является корневым виджетом.
void main() {
  runApp(const MyApp());
}

/// Основной виджет приложения.
///
/// Этот виджет создаёт приложение с материал-дизайном и отображает главную
/// страницу с полем ввода для URL изображения, а также кнопкой для загрузки
/// изображения.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

/// Главная страница приложения.
///
/// Содержит элементы управления для загрузки изображения по URL и переключения
/// между полноэкранным режимом и обычным. Также позволяет пользователю
/// изменять уже загруженное изображение.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Контроллер для текстового поля ввода URL.
  final TextEditingController _urlController = TextEditingController();

  /// Текущий URL изображения для отображения.
  String imageUrl = '';

  /// Открыто ли меню.
  bool isMenuOpen = false;

  /// Идентификатор представления для отображения изображения.
  String viewId = 'img-view';

  /// Загружает изображение по URL, указанному в [TextEditingController].
  void _loadImage() {
    setState(() {
      imageUrl = _urlController.text;
      // Генерируем уникальный идентификатор для представления.
      viewId = 'img-view-${DateTime.now().microsecondsSinceEpoch}';
      _updateImageElement();
    });
  }

  /// Регистрирует элемент изображения для отображения в виде [HtmlElementView].
  ///
  /// Использует платформу Web для отображения изображения, полученного по URL.
  void _updateImageElement() {
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) {
        final img = html.ImageElement()
          ..src = imageUrl
          ..style.height = '100%'
          ..style.width = '100%'
          ..style.borderRadius = '12px';
        return img;
      },
    );
  }

  /// Переключает полноэкранный режим для изображения.
  /// Если текущее состояние полноэкранного режима активно, то оно будет отключено.
  /// Если нет, то будет запрашиваться переход в полноэкранный режим.
  void _toggleFullscreen() {
    if (html.document.fullscreenElement != null) {
      exitFullscreen();
    } else {
      requestFullscreen();
    }
  }

  /// Переключает видимость меню.
  void _toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  /// Закрывает меню.
  void _closeMenu() {
    setState(() {
      isMenuOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Размещение изображения в контейнере с заданным соотношением сторон.
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(width: 1),
                      ),
                      child: imageUrl.isNotEmpty
                          ? GestureDetector(
                              onDoubleTap: _toggleFullscreen,
                              child: HtmlElementView(
                                viewType: viewId,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Строка с полем ввода для URL и кнопкой для загрузки изображения.
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration:
                            const InputDecoration(hintText: 'Image URL'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _loadImage,
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          // Если меню открыто, затемняем фон.
          if (isMenuOpen)
            GestureDetector(
              onTap: _closeMenu,
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          // Кнопка для переключения меню, а также кнопки управления полноэкранным режимом.
          Positioned(
            bottom: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isMenuOpen)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        // Кнопка для входа в полноэкранный режим.
                        TextButton(
                          onPressed: () {
                            _toggleFullscreen();
                            _closeMenu();
                          },
                          child: const Text('Enter fullscreen'),
                        ),
                        // Кнопка для выхода из полноэкранного режима.
                        TextButton(
                          onPressed: () {
                            exitFullscreen();
                            _closeMenu();
                          },
                          child: const Text('Exit fullscreen'),
                        ),
                      ],
                    ),
                  ),
                // Кнопка для открытия/закрытия меню.
                FloatingActionButton(
                  onPressed: _toggleMenu,
                  child: const Icon(
                    Icons.add,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
