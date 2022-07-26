import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waddiny/services/addressData.dart';

class PredictionTile extends StatelessWidget {
  final String mainText;
  final String secondaryText;
  final String placeId;

  const PredictionTile({this.placeId, this.mainText, this.secondaryText});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () async {
       await Provider.of<AddressData>(context, listen: false)
            .getPlaceDeails(placeId);
            

            Navigator.pop(context,'getDirection');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    mainText,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    secondaryText,
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
