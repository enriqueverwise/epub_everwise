import 'package:epub_everwise/domain/entities/epub_style.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class EpubStyleManagerWidget extends StatefulWidget {
  const EpubStyleManagerWidget({super.key, required this.epubStyle});
  final EpubStyle epubStyle;
  @override
  State<EpubStyleManagerWidget> createState() => _EpubStyleManagerWidgetState();
}

class _EpubStyleManagerWidgetState extends State<EpubStyleManagerWidget> {
  late EpubStyle _epubStyle;

  @override
  void initState() {
    super.initState();

    _epubStyle = widget.epubStyle;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            selectBackground(),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                selectScrollDirection(),
                SizedBox(
                  width: 10,
                ),
                selectFontFamily(),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                fontSizeController(),
                SizedBox(
                  width: 10,
                ),
                fontHeightController(),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _epubStyle);
              },
              child: Text(
                "Save changes",
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget fontSizeController() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.2)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          fontSizeBtn(
            onPressed: () {
              setState(() {
                _epubStyle = _epubStyle.copyWith(
                  textStyle: _epubStyle.textStyle.copyWith(
                    fontSize: (_epubStyle.textStyle.fontSize ?? 16) - 1,
                  ),
                );
              });
            },
            icon: Icons.text_decrease_outlined,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(width: 1, color: Colors.white30),
                right: BorderSide(
                  width: 1,
                  color: Colors.white30,
                ),
              ),
            ),
            child: Text("${_epubStyle.textStyle.fontSize}"),
          ),
          fontSizeBtn(
            onPressed: () {
              setState(() {
                _epubStyle = _epubStyle.copyWith(
                  textStyle: _epubStyle.textStyle.copyWith(
                    fontSize: (_epubStyle.textStyle.fontSize ?? 16) + 1,
                  ),
                );
              });
            },
            icon: Icons.text_increase_outlined,
          ),
        ],
      ),
    );
  }

  Widget selectBackground() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Background",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              backgroundItem(EpubBackgroundOption.everwiseColor),
              const SizedBox(
                width: 10,
              ),
              backgroundItem(EpubBackgroundOption.dark),
              const SizedBox(
                width: 10,
              ),
              backgroundItem(EpubBackgroundOption.light),
            ],
          ),
        ],
      ),
    );
  }

  Widget backgroundItem(EpubBackgroundOption bgOption) {
    bool isSelected = _epubStyle.backgroundOption == bgOption;

    return InkWell(
      onTap: () {
        setState(() {
          _epubStyle = _epubStyle.copyWith(
            backgroundOption: bgOption,
          );
        });
      },
      child: Container(
          height: 70,
          width: 70,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15),
            border: isSelected
                ? Border.all(
                    color: Colors.white,
                  )
                : null,
            color: bgOption.color,
          ),
          child: Center(
            child: Text(
              bgOption.text,
              style: TextStyle(
                color: bgOption.isDark ? Colors.white : Colors.black,
              ),
            ),
          )),
    );
  }

  Widget fontHeightController() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.2)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          fontSizeBtn(
            onPressed: () {
              setState(() {
                _epubStyle = _epubStyle.copyWith(
                  textStyle: _epubStyle.textStyle.copyWith(
                    height: (_epubStyle.textStyle.height ?? 1.2) - 0.1,
                  ),
                );
              });
            },
            icon: Icons.format_line_spacing_rounded,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(width: 1, color: Colors.white30),
                right: BorderSide(
                  width: 1,
                  color: Colors.white30,
                ),
              ),
            ),
            child: Text("${_epubStyle.textStyle.height?.toStringAsFixed(2)}"),
          ),
          fontSizeBtn(
            onPressed: () {
              setState(() {
                _epubStyle = _epubStyle.copyWith(
                  textStyle: _epubStyle.textStyle.copyWith(
                    height: (_epubStyle.textStyle.height ?? 1.2) + 0.1,
                  ),
                );
              });
            },
            icon: Icons.format_line_spacing,
          ),
        ],
      ),
    );
  }

  Widget fontSizeBtn({required Function() onPressed, required IconData icon}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon),
      ),
    );
  }

  Widget selectFontFamily() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Font Family",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              fontItem(
                fontFamily: "Times",
              ),
              fontItem(
                fontFamily: "Modern",
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget fontItem({required String fontFamily}) {
    bool isSelected = _epubStyle.textStyle.fontFamily == fontFamily;

    return InkWell(
      onTap: () {
        setState(() {
          _epubStyle = _epubStyle.copyWith(
            textStyle: _epubStyle.textStyle.copyWith(
              fontFamily: fontFamily,
            ),
          );
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(
                  color: Colors.white,
                )
              : null,
        ),
        child: Text(fontFamily),
      ),
    );
  }

  Widget selectScrollDirection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Scroll Direction",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              scrollDirectionItem(
                scrollDirection: Axis.vertical,
              ),
              scrollDirectionItem(
                scrollDirection: Axis.horizontal,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget scrollDirectionItem({required Axis scrollDirection}) {
    bool isSelected = _epubStyle.scrollDirection == scrollDirection;

    return InkWell(
      onTap: () {
        setState(() {
          _epubStyle = _epubStyle.copyWith(
            scrollDirection: scrollDirection,
          );
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(
                  color: Colors.white,
                )
              : null,
        ),
        child: Icon(scrollDirection == Axis.vertical
            ? Icons.arrow_circle_up_rounded
            : Icons.arrow_circle_right_rounded),
      ),
    );
  }
}
