import ballerinax/googleapis_sheets as sheets;
import ballerina/config;
import ballerina/log;

sheets:SpreadsheetConfiguration config = {
    oauth2Config: {
        accessToken: "<Access token here>",
        refreshConfig: {
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET"),
            refreshUrl: config:getAsString("REFRESH_URL"),
            refreshToken: config:getAsString("REFRESH_TOKEN")
        }
    }
};

sheets:Client spreadsheetClient = new (config);

public function main() {
    string spreadsheetId = "";
    string sheetName = "";
    int sheetId = 0;

    // Create Spreadsheet with given name
    sheets:Spreadsheet|error response = spreadsheetClient->createSpreadsheet("NewSpreadsheet");
    if (response is sheets:Spreadsheet) {
        log:print("Spreadsheet Details: " + response.toString());
        spreadsheetId = response.spreadsheetId;
    } else {
        log:printError("Error: " + response.toString());
    }

    // Add a New Worksheet with given name to the Spreadsheet with the given Spreadsheet ID 
    sheets:Sheet|error sheet = spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
    if (sheet is sheets:Sheet) {
        log:print("Sheet Details: " + sheet.toString());
        sheetName = sheet.properties.title;
        sheetId = sheet.properties.sheetId;
    } else {
        log:printError("Error: " + sheet.toString());
    }

    string a1Notation = "A1:D5";
    string[][] entries = [
        ["Name", "Score", "Performance", "Average"],
        ["Keetz", "12"],
        ["Niro", "78"],
        ["Nisha", "98"],
        ["Kana", "86"]
    ];
    sheets:Range range = {a1Notation: a1Notation, values: entries};

    // Sets the values of the given range of cells of the Sheet
    error? spreadsheetRes = spreadsheetClient->setRange(spreadsheetId, sheetName, range);
    if (spreadsheetRes is ()) {
        // Inserts the given number of rows before the given row position in a Worksheet with given ID.
        error? rowBeforeId = checkpanic spreadsheetClient->addRowsBefore(spreadsheetId, sheetId, 4, 1);
        // Inserts the given number of rows before the given row position in a Worksheet with given name.
        error? rowBefore = checkpanic spreadsheetClient->addRowsBeforeBySheetName(spreadsheetId, sheetName, 5, 1);        
        // Inserts the given number of rows after the given row position in a Worksheet with given ID.
        error? rowAfterId = checkpanic spreadsheetClient->addRowsAfter(spreadsheetId, sheetId, 6, 1);
        // Inserts the given number of rows after the given row position in a Worksheet with given name.
        error? rowAfter = checkpanic spreadsheetClient->addRowsAfterBySheetName(spreadsheetId, sheetName, 7, 1);
        // Create or Update a Row with the given array of values in a Worksheet with given name.
        string[] values = ["Update", "Row", "Values"];
        error? rowCreate = checkpanic spreadsheetClient->createOrUpdateRow(spreadsheetId, sheetName, 10, values);
        // Gets the values in the given row in a Worksheet with given name.
        (string|int|float)[]|error row = spreadsheetClient->getRow(spreadsheetId, sheetName, 10);
        if (row is (string|int|float)[]) {
            log:print(row.toString());
        } else {
            log:printError("Error: " + row.toString());
        }
        // Deletes the given number of rows starting at the given row position in a Worksheet with given ID.
        error? rowDeleteId = checkpanic spreadsheetClient->deleteRows(spreadsheetId, sheetId, 4, 2);
        // Deletes the given number of rows starting at the given row position in a Worksheet with given name.
        error? rowDelete = checkpanic spreadsheetClient->deleteRowsBySheetName(spreadsheetId, sheetName, 5, 2);

        // Gets the given range of the Sheet
        sheets:Range|error getValuesResult = spreadsheetClient->getRange(spreadsheetId, sheetName, a1Notation);
        if (getValuesResult is sheets:Range) {
            log:print("Range Details: " + getValuesResult.values.toString());
        } else {
            log:printError("Error: " + getValuesResult.toString());
        }
    } else {
        log:printError("Error: " + spreadsheetRes.toString());
    }
}
