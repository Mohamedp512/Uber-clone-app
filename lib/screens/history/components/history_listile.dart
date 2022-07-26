import 'package:flutter/material.dart';
import 'package:waddiny/models/history.dart';
import 'package:waddiny/size_config.dart';

class HistoryListile extends StatelessWidget {
  History history;
  HistoryListile({this.history});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.defaultSize,vertical: SizeConfig.defaultSize*1.2),
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/pickicon.png',
                height: SizeConfig.defaultSize * 1.6,
                width: SizeConfig.defaultSize * 1.6,
              ),
              SizedBox(
                width: SizeConfig.defaultSize * 1.8,
              ),
              Flexible(
                              child: Container(
                  child: Text(
                    history.pickUp,
                    overflow: TextOverflow.ellipsis,softWrap: true,
                    style: TextStyle(fontSize: SizeConfig.defaultSize * 1.8),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.defaultSize,),
              Text(
                '\$${history.fares}',
                style: TextStyle(
                  fontFamily: 'Brand-Bold',
                  fontSize: SizeConfig.defaultSize * 1.6,
                ),
              )
            ],
          ),
          /* SizedBox(
            height: SizeConfig.defaultSize,
          ), */
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                'assets/images/desticon.png',
                height: SizeConfig.defaultSize * 1.6,
                width: SizeConfig.defaultSize * 1.6,
              ),
              SizedBox(
                width: SizeConfig.defaultSize * 1.8,
              ),
              Text(
                history.destination,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: SizeConfig.defaultSize * 1.8),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.defaultSize*1.5,),
          Text(
            history.createdAt,
            style: TextStyle(color: Colors.black38),
          )
        ],
      ),
    );
  }
}