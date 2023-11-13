import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_intra/model/files.dart';
import 'package:my_intra/utils/get_files_project.dart';

import '../consts.dart' as consts;
import '../model/projects.dart';
import 'download_file.dart';

Future<void> showFileModal(Projects project, BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.symmetric(horizontal: 0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          content: SizedBox(
            width: 332,
            height: 375,
            child: FutureBuilder(
                future: getFilesForProject(project.filesUrl),
                builder: (context, AsyncSnapshot<List<File>> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        border: Border.all(color: Color(consts.borderColor)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "Files available",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 30),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              bool downloading = false;
                              return StatefulBuilder(
                                  builder: (context, setStateDownload) {
                                return Container(
                                  padding: const EdgeInsets.only(
                                      left: 9, right: 9, top: 10, bottom: 10),
                                  constraints: const BoxConstraints(
                                      minHeight: 52, minWidth: 322),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      border: Border.all(
                                          width: 2,
                                          color: const Color(0xFFC8D1E6))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                          child: Text(
                                        snapshot.data![index].name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                      downloading == false
                                          ? InkWell(
                                              child: Container(
                                                width: 90,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                  border: Border.all(
                                                      width: 2,
                                                      color: const Color(
                                                          0xFFC8D1E6)),
                                                  color:
                                                      const Color(0xFF7293E1),
                                                ),
                                                child: Center(
                                                    child: Text(
                                                  "Download",
                                                  style: GoogleFonts.openSans(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                )),
                                              ),
                                              onTap: () async {
                                                setStateDownload(() {
                                                  downloading = true;
                                                });
                                                await downloadFile(
                                                    snapshot.data![index].url,
                                                    snapshot.data![index].name);
                                                setStateDownload(() {
                                                  downloading = false;
                                                });
                                              },
                                            )
                                          : CircularProgressIndicator()
                                    ],
                                  ),
                                );
                              });
                            },
                          )
                        ],
                      ),
                    );
                  } else if (snapshot.hasData == false &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return Center(child: Text("No files available"));
                  }
                }),
          ),
        );
      });
}
