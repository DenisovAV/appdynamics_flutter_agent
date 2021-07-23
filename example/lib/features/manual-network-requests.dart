/*
 * Copyright (c) 2021. AppDynamics LLC and its affiliates.
 * All rights reserved.
 *
 */

import 'package:appdynamics_mobilesdk/appdynamics_mobilesdk.dart';
import 'package:appdynamics_mobilesdk_example/utils/flush-beacons-app-bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManualNetworkRequests extends StatefulWidget {
  @override
  _ManualNetworkRequestsState createState() => _ManualNetworkRequestsState();
}

class _ManualNetworkRequestsState extends State<ManualNetworkRequests> {
  final urlFieldController =
      TextEditingController(text: "https://www.appdynamics.com");
  var responseText = "";
  var addServerCorrelation = true;

  @override
  void dispose() {
    urlFieldController.dispose();
    super.dispose();
  }

  Future<void> _sendGetRequestButtonPressed() async {
    var urlString = urlFieldController.text;
    if (urlString.trim().isNotEmpty) {
      final url = Uri.parse(urlString);

      var headers = null;
      if (addServerCorrelation) {
        headers = await RequestTracker.getServerCorrelationHeaders();
      }
      final request = http.get(url, headers: headers);
      _sendManualReportedRequest(request, urlString);
    }
  }

  Future<void> _sendPostRequestButtonPressed() async {
    var urlString = urlFieldController.text;
    if (urlString.trim().isNotEmpty) {
      final url = Uri.parse(urlString);

      var headers = null;
      if (addServerCorrelation) {
        headers = await RequestTracker.getServerCorrelationHeaders();
      }
      final request = http.get(url, headers: headers);
      _sendManualReportedRequest(request, urlString);
    }
  }

  Future<void> _sendManualReportedRequest(
      Future<http.Response> request, String urlString) async {
    setState(() {
      responseText = "Loading...";
    });

    final tracker = await RequestTracker.create(urlString);
    try {
      final response = await request;
      tracker.setResponseStatusCode(response.statusCode);
      tracker.setRequestHeaders(response.request!.headers);
      tracker.setResponseHeaders(response.headers);
      setState(() {
        responseText = "Success with ${response.statusCode}.";
      });
    } catch (e) {
      setState(() {
        responseText = "Failed with ${e.toString()}.";
      });
      tracker.setError(e.toString());
    } finally {
      tracker.reportDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlushBeaconsAppBar(
        title: 'Manual network requests',
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Text('Add server correlation headers: '),
                Checkbox(
                  value: this.addServerCorrelation,
                  onChanged: (bool? value) {
                    setState(() {
                      this.addServerCorrelation = value!;
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 80, 50, 10),
              child: TextFormField(
                key: Key("requestTextField"),
                controller: urlFieldController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter URL to report',
                    hintText: 'https://www.appdynamics.com'),
              ),
            ),
            Visibility(
              child: Text(
                responseText,
                textAlign: TextAlign.center,
              ),
              visible: !responseText.isEmpty,
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
                key: Key("manualGETRequestButton"),
                child: Text('Manual track GET request'),
                onPressed: _sendGetRequestButtonPressed),
            ElevatedButton(
                key: Key("manualPOSTRequestButton"),
                child: Text('Manual track POST request'),
                onPressed: _sendPostRequestButtonPressed),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}