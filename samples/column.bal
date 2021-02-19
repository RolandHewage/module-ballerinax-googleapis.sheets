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
        // Inserts the given number of columns before the given column position in a Worksheet with given ID.
        error? columnBeforeId = checkpanic spreadsheetClient->addColumnsBefore(spreadsheetId, sheetId, 3, 1);
        // Inserts the given number of columns before the given column position in a Worksheet with given name.
        error? columnBefore = checkpanic spreadsheetClient->addColumnsBeforeBySheetName(spreadsheetId, sheetName, 4, 1);        
        // Inserts the given number of columns after the given column position in a Worksheet with given ID.
        error? columnAfterId = checkpanic spreadsheetClient->addColumnsAfter(spreadsheetId, sheetId, 5, 1);
        // Inserts the given number of columns after the given column position in a Worksheet with given name.
        error? columnAfter = checkpanic spreadsheetClient->addColumnsAfterBySheetName(spreadsheetId, sheetName, 6, 1);
        // Create or Update a Column with the given array of values in a Worksheet with given name.
        string[] values = ["Update", "Column", "Values"];
        error? columnCreate = checkpanic spreadsheetClient->createOrUpdateColumn(spreadsheetId, sheetName, "I", values);
        // Gets the values in the given column in a Worksheet with given name.
        (string|int|float)[]|error column = spreadsheetClient->getColumn(spreadsheetId, sheetName, "I");
        if (column is (string|int|float)[]) {
            log:print(column.toString());
        } else {
            log:printError("Error: " + column.toString());
        }
        // Deletes the given number of columns starting at the given column position in a Worksheet with given ID.
        error? columnDeleteId = checkpanic spreadsheetClient->deleteColumns(spreadsheetId, sheetId, 3, 2);
        // Deletes the given number of columns starting at the given column position in a Worksheet with given name.
        error? columnDelete = checkpanic spreadsheetClient->deleteColumnsBySheetName(spreadsheetId, sheetName, 4, 2);

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
