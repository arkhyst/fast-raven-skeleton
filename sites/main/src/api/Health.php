<?php

use FastRaven\Components\Http\Request;
use FastRaven\Components\Http\Response;

use FastRaven\Workers\LogWorker;

return function(Request $request): Response {
    LogWorker::log("Health API call was processed successfully");
    return Response::new(true, 200);
};