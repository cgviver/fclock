import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class AnalogicCircle extends StatelessWidget {
  const AnalogicCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    bool isPortait = height > width;
    return SizedBox(
      height: isPortait ? height * 0.5 : height * 0.6,
      width: width * 0.7,
      child: Neumorphic(
        margin: EdgeInsets.all(14),
        style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.circle(),
        ),
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: 14,
            boxShape: NeumorphicBoxShape.circle(),
          ),
          margin: EdgeInsets.all(20),
          child: Neumorphic(
            style: NeumorphicStyle(
              depth: -8,
              boxShape: NeumorphicBoxShape.circle(),
            ),
            margin: EdgeInsets.all(10),
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                //the click center
                Neumorphic(
                  style: NeumorphicStyle(
                    depth: -1,
                    boxShape: NeumorphicBoxShape.circle(),
                  ),
                  margin: EdgeInsets.all(65),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: Stack(
                //     children: <Widget>[
                //       Align(
                //         alignment: Alignment(-0.7, -0.7),
                //         child: _createDot(context),
                //       ),
                //       Align(
                //         alignment: Alignment.centerLeft,
                //         child: _createDot(context),
                //       ),
                //       Align(
                //         alignment: Alignment(-0.7, -0.7),
                //         child: _createDot(context),
                //       ),
                //       Align(
                //         alignment: Alignment(0.7, -0.7),
                //         child: _createDot(context),
                //       ),
                //       Align(
                //         alignment: Alignment(-0.7, 0.7),
                //         child: _createDot(context),
                //       ),
                //       Align(
                //         alignment: Alignment(0.7, 0.7),
                //         child: _createDot(context),
                //       ),
                //       Align(
                //         alignment: Alignment.centerRight,
                //         child: _createDot(context),
                //       ),
                //       Align(
                //         alignment: Alignment.bottomCenter,
                //         child: _createDot(context),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createDot(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -10,
        boxShape: NeumorphicBoxShape.circle(),
      ),
      child: SizedBox(
        height: 10,
        width: 10,
      ),
    );
  }
}
