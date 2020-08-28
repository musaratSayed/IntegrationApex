@RestResource(urlMapping='/Cases/*')
global class CaseManagerApexRestClass {
    @HttpGet
    global static Case getCaseById()
    {
        RestRequest req = RestContext.request;
        String caseId=req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Case result = [Select CaseNumber,Status,Origin,Priority,Subject From Case where Id =: caseId];
        return result;
    }
    
    @HttpPost
    global static Id createCase(String s, String Sta, string pri, String ori)
    {
        Case c = new Case(Subject=s,Status=Sta,Priority=pri,Origin=ori);
        insert c;
        return c.Id;
    }
    
    @HttpDelete
    global static void deleteCase()
    {
        RestRequest req = RestContext.request;
        String caseId=req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Case result = [Select CaseNumber,Status,Origin,Priority,Subject From Case where Id =: caseId];
        delete result;
    }
    
    @HttpPut
    global static ID upsertCase(String sub,String Status, String origin, String Pri, String id)
    {
        
          Case c = new Case(Id=id,Subject=sub,Status=Status,Priority=Pri,Origin=origin); 
        upsert c;
        return c.Id;
    }
    
    @HttpPatch
    global static Id updateCaseFields()
    {
        RestRequest req = RestContext.request;
        String caseId=req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Case result = [Select Id From Case where Id =: caseId];
        Map<String,Object> params=(Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
        for(String fieldName:params.keySet())
        {
            result.put(fieldName,params.get(fieldName));
        }
 		update result;
        return result.Id;
    }

}