import 'package:_first_one/models/documents_manager.dart';
import 'package:_first_one/views/view_documents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(30.w, 30.h, 30.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Text(
                "Categories ",
                style: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _getIcon(Icons.search),
                  SizedBox(
                    child: Row(
                      children: [
                        _getIcon(Icons.apps),
                        Container(
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 250, 212, 98)),
                            child: _getIcon(Icons.splitscreen))
                      ],
                    ),
                  ),
                ],
              ),
              InkWell(
                  onTap: () {
                    var list = DocumentManager().identityImages;
                    if (list != null) {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return ViewDocuments(
                          documentCategory: DocumentCategory.identity,
                          title: "Identity Documents",
                        );
                      }));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text("You have no Identity documents to show")));
                    }
                  },
                  child: _getBar(Icons.remember_me_outlined, "Identity")),
              InkWell(
                  onTap: () {
                    var list = DocumentManager().educationImages;
                    if (list != null) {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return ViewDocuments(
                          documentCategory: DocumentCategory.education,
                          title: "Education Documents",
                        );
                      }));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text("You have no Identity documents to show")));
                    }
                  },
                  child: _getBar(Icons.school, "Education")),
              _getBar(Icons.currency_rupee_outlined, "Finance"),
              _getBar(Icons.airplane_ticket, "Travel"),
              _getBar(Icons.vpn_key, "Passes"),
              _getBar(Icons.health_and_safety, "Health"),
              _getBar(Icons.inventory_2, "Others"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getBar(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: 0,
        top: 20.h,
      ),
      child: Container(
        height: 45.h,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Color(0xFFED91FF),
            borderRadius: BorderRadius.circular(45),
            border: Border.all(color: Color(0xFF580F66), width: 2)),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 20.w,
            ),
            Icon(
              icon,
              color: Color(0xFF580F66),
              size: 28,
            ),
            SizedBox(
              width: 16.w,
            ),
            Text(
              title,
              style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF580F66)),
            )
          ],
        ),
      ),
    );
  }

  Widget _getIcon(IconData icon) {
    return Icon(
      icon,
      size: 37,
      color: Color(0xFF580F66),
    );
  }
}
