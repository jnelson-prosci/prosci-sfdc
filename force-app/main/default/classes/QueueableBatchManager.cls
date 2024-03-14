/**
 * @author CloudMasonry
 * @date 2021
 * @group Queueable
 * @description Facilitates chaining Queueables to operate similar to an Apex Batch by defining a batch size for 
 *              each queueable execution, and returning the set of record ids to process within a
 *              given queueable, as well as the set of unprocessed ids to process in the next queueable
 *              iteration. Class was created to constrain a queueable to process records within the callout limit.
 */
public with sharing class QueueableBatchManager {

    public enum Context { Callout }
    Set<Id> setIds;
    Context enumContext;
    Integer intDenominator;
    // if Batch Limit should have other definition, should create a methodor condition to set the limit per context
    @testVisible
    private Integer BATCH_LIMIT {
        get {
            if(BATCH_LIMIT == null){
                BATCH_LIMIT = getBatchLimit();
            }
            return BATCH_LIMIT;
        }
        set;
    }

    @testVisible
    private Integer BATCH_SIZE {
        get {
            if(BATCH_SIZE == null){
                BATCH_SIZE = this.setIds.size() < BATCH_LIMIT ? this.setIds.size() : BATCH_LIMIT;
            }
            return BATCH_SIZE;
        }
        set;
    }

    private Set<Id> setBatchIds {
        get {
            if(setBatchIds == null){
                setBatchIds = new Set<Id>();
                List<Id> lstIds = new List<Id>(this.setIds);
                for(Integer i=0; i < BATCH_SIZE; i++){
                    setBatchIds.add(lstIds[i]);
                }
            }
            return setBatchIds;
        }
        private set;
    }

    private Set<Id> setUnprocessedIds {
        get {
            setUnprocessedIds = new Set<Id>();
            setUnprocessedIds.addAll(setIds);
            setUnprocessedIds.removeAll(setBatchIds);
            return setUnprocessedIds;
        }
        private set;
    }

    /**
     * Class Constructor
     */
    public QueueableBatchManager(){
        this.setIds = new Set<Id>();
    }

    public QueueableBatchManager(Context enumContext, Integer intDenominator){
        this.setIds = new Set<Id>();
        this.enumContext = enumContext;
        this.intDenominator = intDenominator;
    }

    /**
     * Sets setIds
     * @param  setIds Set of Record Ids from context
     */
    public void setIds(Set<Id> setIds){
        this.setIds = setIds;
    }

    /**
     * Returns Set of Record Ids for current batch scope
     * @return   Set<Id> Record Ids for current batch scope
     */
    public Set<Id> getBatchIds(){
        return setBatchIds;
    }

    /**
     * Returns Set of Record Ids not included in current batch scope
     * @return   Set<Id> Record Ids not included in current batch scope
     */
    public Set<Id> getUnprocessedIds(){
        return setUnprocessedIds;
    }

    private Integer getBatchLimit(){
        Integer batchLimit = 200;
        if(this.enumContext == Context.Callout){
            batchLimit = Integer.valueOf(Math.floor(Limits.getLimitCallouts() / intDenominator));
        }
        return batchLimit;
    }

}