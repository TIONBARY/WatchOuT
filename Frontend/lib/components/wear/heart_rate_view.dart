import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/providers/heart_rate_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class HeartRateView extends StatefulWidget {
  const HeartRateView({
    Key? key,
    required this.margins,
    required this.provider,
  }) : super(key: key);
  final EdgeInsetsGeometry margins;
  final HeartRateProvider provider;

  @override
  State<HeartRateView> createState() => _HeartRateViewState();
}

class _HeartRateViewState extends State<HeartRateView> {
  @override
  void initState() {
    super.initState();
    // debugPrint("심박수꺼");
    // SharedPreferences.getInstance().then(
    //   (value) => {
    //     debugPrint(value.hashCode.toString()),
    //     debugPrint(value.getBool("useWearOS").toString())
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    SfRangeValues _values =
        SfRangeValues(widget.provider.minValue, widget.provider.maxValue);
    return Flexible(
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 0.5.h, 5.w, 0.5.h),
        // padding: EdgeInsets.fromLTRB(5.w, 0.h, 5.w, 0.h),
        margin: widget.margins,
        decoration: BoxDecoration(
          color: b25Color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: b25Color.withOpacity(0.125),
              offset: Offset(0, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '나의 심박수 범위 : ',
              style: TextStyle(
                fontFamily: 'HanSan',
              ),
            ),
            // ${widget.provider.heartRate}
            SizedBox(
              height: 5.85.h,
              child: SfRangeSliderTheme(
                data: SfRangeSliderThemeData(),
                child: SfRangeSlider(
                  min: 40.0,
                  max: 200.0,
                  values: _values,
                  activeColor: yColor,
                  inactiveColor: y50Color,
                  // shouldAlwaysShowTooltip: true,
                  showLabels: true,
                  enableTooltip: true,
                  tooltipTextFormatterCallback:
                      (dynamic actualValue, String formattedText) {
                    return actualValue.toStringAsFixed(0);
                  },
                  minorTicksPerInterval: 1,
                  onChanged: (SfRangeValues values) {
                    setState(() {
                      _values = values;
                      widget.provider.changeMinValue(values.start);
                      widget.provider.changeMaxValue(values.end);
                      // save();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
