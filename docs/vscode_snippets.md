# VS Code snippets for SQL

Press F1, enter "snippets", select "Preferences: Configure user snippets" or "Insert Snippet".
Select language you need.

    {
    	// Place your snippets for sql here. Each snippet is defined under a snippet name and has a prefix, body and 
    	// description. The prefix is what is used to trigger the snippet and the body will be expanded and inserted. Possible variables are:
    	// $1, $2 for tab stops, $0 for the final cursor position, and ${1:label}, ${2:another} for placeholders. Placeholders with the 
    	// same ids are connected.
    	"Select top": {
    		"prefix": "select top",
    		"body": [
    			"SELECT TOP ${N} * FROM ${tablename};",
    			"$0"
    		],
    		"description": "Select top N from the table"
    	},
    	"Use": {
    		"prefix": "use",
    		"body": [
    			"USE ${db};",
    			"$0"
    		],
    		"description": "Use some database"
    	},
    	"Get version": {
    		"prefix": "@ver",
    		"body": [
    			"SELECT @@VERSION as [Version];"
    		],
    		"description": "Get version of SQL Server"
    	}
    
    }

The first one will prompt number of rows to select (press Tab) tablename (Tab), thats all.

The second one will prompt DB name, the last one just generate a query to get SQL Server version.
