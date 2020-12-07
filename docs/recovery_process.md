# Four phase SQL Server database recovery process

Whenever a sql server gets restarting it goes through the recovery process and there are two types of recovery both having the aim of making sure the logs and data agree.

## Restart Recovery (also known as Crash Recovery)

Occurs every time SQL Server is restarted. The process runs on each database as each DB has its own transaction log (SQL Server 2008 uses multiple threads to process the recovery operations on the different databases simultaneously to speed recovery)

## Restore Recovery

Occurs when a restore operation is executed. This process makes sure all the committed transactions in the backup of the transaction log are reflected in the data and any tranactions that did not commit do not show up in the data.

## Four consecutive phases that take place during SQL Server recovery

1. *Discovery* – is to find the logical structure of the Transaction log file.
2. *Analysis* – is to find the best LSN starting from which rolling forward can be done during redo phase.
3. *Redo* – is the phase during which the changes caused by active transactions (at the time of crash) are hardened onto Data files.
4. *Undo* – is the phase where in, rolling back of the active transactions for consistency, takes place.

### Discovery Phase

The first phase of recovering a database is called discovery where all the VLFs are scanned (in serial and single threaded fashion) before actual recovery starts. Since this happens much before the analysis phase, there are no messages indicating the progress in the SQL Server error log. Depending on the number of VLFs this initial discovery phase can take several hours even if there are no transactions in the log that need to be processed.

This is the reason why it is preferred to have optimal number of VLFs in a log file.

*Virtual Log File*

In SQL Server, each transaction log is logically divided into smaller segments, in which the log records are written. These small segments are called SQL Virtual Log Files, also known as VLFs. When the transaction log file is created or extended, the number of SQL Server VLFs in the transaction log and the size of each Virtual Log File are determined dynamically. On the other hand, the size that is determined for the first Virtual Log File will be used for all newly created SQL Virtual Log Files on the same transaction log. 

### Analysis Phase

Preparation of *Dirty Page Table* (DPT) and *Active Transaction Table* (ATT) are the prime motives of Analysis phase. These two tables are put to use by SQL Server during subsequent redo and undo phases respectively.

To create DPT, SQL Server requires to make a note all the pages and their LSNs that might have been dirty (à not yet hardened) at the time of crash, from the transaction log (.ldf), so that during redo phase all such pages will be rolled forward and at the end of redo phase the database would be in such a state as if it was just before crash.

As all the pages prior to last checkpoint would have been already hardened and the pages after the last checkpoint are the ones that are dirty but yet to get hardened. Hence analysis phase starts (in the sense SQL Server starts reading using the .ldf) from the last checkpoint LSN till end of transaction log.

Scanning through the transaction log from the latest checkpoint till end of transaction log prepares the list of all pages that are dirty and obviously not hardened as they are after checkpoint. This list is the DPT. The minimum of all the LSNs available from DPT will be the minimum recovery LSN. Similarly using transaction log file, active transaction table is generated.

### Redo Phase

*Rolling forward all the changes that took place after the checkpoint and just before the crash so that at the end of redo phase the db would be in a state as if it was just before the crash*, is the intent of redo phase.

Hence making use of minimum recovery LSN obtained from DPT, starting from the minimum recovery LSN and till the LSN at end of transaction log, SQL server rolls forward (hardens) all the changes that are present in all the dirty (not yet hardened) pages and brings the db to the desired state.

### Undo Phase

Ensuring that the data integrity is not hampered so that db can be opened for access is the aim of Undo phase. For this, all the changes made by all the transactions that were active at the time of crash are to be rolled back.

Hence, SQL server, using ATT , starting from LSN at the end of transaction log will rollback all the changes caused by all the active transactions till the LSN of beginning of oldest transaction(among the active transactions present in ATT), which is available from transaction log and opens the database for user access.