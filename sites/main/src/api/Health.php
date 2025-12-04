<?php

use SmartGoblin\Components\Http\Request;
use SmartGoblin\Components\Http\Response;

use SmartGoblin\Workers\LogWorker;

return function(Request $request): Response {
    LogWorker::log("Health API call was processed successfully");
    return Response::new(true, 200);
};