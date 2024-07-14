import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/src/utils.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget _getMobileNoField(BuildContext context) {
  var dPhoneCode = "91";
  var dCountryCode = "IN";

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 10.w,
      ),
      Text(
        Utils.countryCodeToEmoji(dCountryCode),
        style: TextStyle(fontSize: 18.sp),
      ),
      SizedBox(
        width: 10.w,
      ),
      Text(
        "$dPhoneCode",
        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18.sp),
      ),
      IconButton(
        onPressed: () {
          showCountryPicker(
              context: context,
              showPhoneCode: true,
              countryListTheme: CountryListThemeData(bottomSheetHeight: 400.h),
              showSearch: true,
              onSelect: (Country country) {
                print("${country.displayName}   ${country.countryCode}");
                dCountryCode = country.countryCode;
                dPhoneCode = country.phoneCode;
                //setState(() {});
              });
        },
        icon: Icon(
          CupertinoIcons.arrowtriangle_down_fill,
          size: 15.sp,
        ),
      ),
      SizedBox(
        width: 170.w,
        height: 45.h,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 3.h),
          child: TextField(
            style: TextStyle(
                fontSize: 18.sp,
                fontStyle: FontStyle.italic,
                letterSpacing: 3.w),
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter 10 digit mobile no",
                hintStyle: TextStyle(
                    fontSize: 12.sp,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1)),
            keyboardType: TextInputType.number,
          ),
        ),
      )
    ],
  );
}
