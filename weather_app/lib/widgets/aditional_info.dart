import 'package:flutter/material.dart';

class Additional_info extends StatelessWidget {
  final IconData icon;
  final String state;
  final double value;
  const Additional_info({super.key,
  required this.icon,
  required this.state,
  required this.value
  
  
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Icon(icon,size: 30,),
                      Text(state,style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      ),),
                      Text(value.toString(),style: TextStyle(
                
                        fontSize: 18
                      ),)

                    ],
                  
                  ),
                );
  }
}