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

    string a1Notation = "B2:E6";
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
        // Append a new cell with the given value to the bottom of the range in a Worksheet with given name. 
        // The input range is used to search for existing data and find a "table" within that range. Value is appended 
        // to the next row of the table, starting with the first column of the table. If the range is not in any table 
        // the value is written to the given cell
        error? append = checkpanic spreadsheetClient->appendCell(spreadsheetId, sheetName, "D6", "Modified Value1");
        error? appendNext = checkpanic spreadsheetClient->appendCell(spreadsheetId, sheetName, a1Notation, "Modified Value2");

        // Gets the given range of the Sheet
        string a1NotationAppend = "B2:E8";
        sheets:Range|error getValuesResult = spreadsheetClient->getRange(spreadsheetId, sheetName, a1NotationAppend);
        if (getValuesResult is sheets:Range) {
            log:print("Range Details: " + getValuesResult.values.toString());
        } else {
            log:printError("Error: " + getValuesResult.toString());
        }
    } else {
        log:printError("Error: " + spreadsheetRes.toString());
    }
}
