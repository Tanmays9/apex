public inherited sharing class caseDelete {
    @future
    public static void deleteEmailCase(List<ID> caseID) {
        system.debug([SELECT ID FROM Case WHERE id IN :caseID]);
        delete [SELECT ID FROM Case WHERE id IN :caseID];
    }
}