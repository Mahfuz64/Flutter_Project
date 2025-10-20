import 'package:flutter/material.dart';

class hourlyforcast extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;
  const hourlyforcast({
    super.key,
    required this.time,
    required this.icon,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return  Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    
                    child: Column(
                      
                      spacing: 6,
                      children: [
                        Text(time),
                        Icon(icon,size: 18),
                        Text(temp),
                        
                        
                      ],
                    ),
                    
                  ),
                );
                
  }
}
