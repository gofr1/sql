USE DEMO;

-- IAM pages are allocated as required for each allocation unit and are located randomly in the file. 
-- The sys.system_internals_allocation_units system view points to the first IAM page for an allocation unit. 
-- All the IAM pages for that allocation unit are linked in an IAM chain.

SELECT *
FROM sys.system_internals_allocation_units;

-- An IAM (Index Allocation Map) page tracks approximately 4GB worth of space in a single file, 
--aligned on a 4GB boundary. These 4GB chunks are called ‘GAM intervals’. 
-- An IAM page tracks which extents within that specific GAM interval belongs to a single entity

DBCC IND ('DEMO', IndexTest, -2); 

--* PageFID PagePID PageType
--! 3       8       10
--* 3       9       10

DBCC TRACEON (3604);
DBCC PAGE ('DEMO', 3, 8, 3);
DBCC TRACEOFF (3604);

-- The output:
--!     m_pageId = (3:8) m_headerVersion = 1 m_type = 10
--*     m_typeFlagBits = 0x0 m_level = 0 m_flagBits = 0x200
--*     m_objId (AllocUnitId.idObj) = 215 m_indexId (AllocUnitId.idInd) = 256 
--* 
--*     Metadata: AllocUnitId = 72057594052018176 
--*     Metadata: PartitionId = 72057594045399040 Metadata: IndexId = 1
--*     Metadata: ObjectId = 1221579390 m_prevPage = (0:0) m_nextPage = (3:9)
--* 
--*     pminlen = 90 m_slotCnt = 2 m_freeCnt = 6
--*     m_freeData = 8182 m_reservedCnt = 0 m_lsn = (47:27400:77)
--*     m_xactReserved = 0 m_xdesId = (0:0) m_ghostRecCnt = 0
--*     m_tornBits = 520171237 DB Frag ID = 1 
--* 
--* Allocation Status
--* 
--*     GAM (3:2) = ALLOCATED SGAM (3:3) = ALLOCATED 
--*     PFS (3:1) = 0x70 IAM_PG MIXED_EXT ALLOCATED 0_PCT_FULL DIFF (3:6) = NOT CHANGED
--*     ML (3:7) = NOT MIN_LOGGED 
--* 
--* IAM: Header @0x0000000632528064 Slot 0, Offset 96
--?    sequenceNumber = 0 status = 0x0 objectId = 0
--?    indexId = 0 page_count = 0 start_pg = (3:0)

-- The IAM page header has the following fields:
-- 
--! sequenceNumber
--     This is the position of the IAM page in the IAM chain. This increases by one for each page added to the IAM chain.
--! status
--     This is unused.
--! objectId
--! indexId
--     On SQL Server 2000 and before, these are the object  and index IDS that the IAM page is part of. On SQL Server 2005 and later they are unused.
--! page_count
--     This is unused  – it used to be the number of page IDs that are being tracked in the single page allocation array.
--! start_pg
--     This is the GAM interval that the page maps. It stores the first page ID in the mapped interval.
-- Single Page Allocations array
--     These are the pages that have been allocated from mixed extents. This array is only used in the first IAM page in the chain (as the whole IAM chain only need to track at most 8 single-page allocations).


--* IAM: Single Page Allocations @0x000000063252808E
--* 
--*     Slot 0 = (0:0) Slot 1 = (0:0) Slot 2 = (0:0)
--*     Slot 3 = (0:0) Slot 4 = (0:0) Slot 5 = (0:0)
--*     Slot 6 = (0:0) Slot 7 = (0:0) 
--* 
--* IAM: Extent Alloc Status Slot 1 @0x00000006325280C2
--* 
--*     (3:0) - (3:8) = NOT ALLOCATED 
--*     (3:16) - = ALLOCATED 
--*     (3:24) - (3:632) = NOT ALLOCATED 
