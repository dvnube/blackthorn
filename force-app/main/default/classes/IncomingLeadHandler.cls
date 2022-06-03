/**
 * @description An implementation of IHandleMessages which validates the passed in Lead and inserts it.
 */
public with sharing class IncomingLeadHandler implements IHandleMessages {
    @testVisible private static final String INCOMING_LEAD_CHANNEL = 'IncomingLeads';
    @testVisible private static final String INVALID_LEAD_ERROR = 'The Lead specified is invalid.';
    @testVisible private static final String CHANNEL_PARAM = 'channel';

    /**
     * @description Constructs an instance of IncomingLeadHandler.
     */
    public IncomingLeadHandler() { }

    /**
     * @description Handles a message on a subscribed channel.
     * @param channel The channel emitting the message.
     * @param data The accompanying data for the message.
     * @throws ArgumentNullException if channel is null.
     * @throws ArgumentException if the lead is missing a FirstName.
     */
    public void handleMessage(String channel, Object data) {
        //channel is null
        ArgumentNullException.throwIfNull(channel, CHANNEL_PARAM);
        try {
            if (channel.equals(INCOMING_LEAD_CHANNEL)) {
                handleIncomingLeadChannel(data);
            }
        }
    }

    void handleIncomingLeadChannel(Object data) {
        try {
            Lead record = (Lead) data;
            ArgumentNullException.throwIfNull(record.FirstName, 'Lead.FirstName'); //Lead is missing a FirstName

            Database.insert(record);
        } catch (TypeException te) {
            throw new ArgumentException(INVALID_LEAD_ERROR); //data is not a Lead
        } catch (ArgumentNullException ane) {
            throw ane;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Unexpected error: ' + e.getMessage() + ' - Line: ' + e.getLineNumber());
            throw e;
        }
    }

    /**
     * @description Gets a list of channels an implementation subscribes to.
     * @return A List<String> of channel names this implementation is subscribed to.
     */
    public List<String> getSubscribedChannels() {
        return new List<String> {
            INCOMING_LEAD_CHANNEL
        };
    }
}