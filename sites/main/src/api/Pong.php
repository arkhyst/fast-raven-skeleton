<?php

use FastRaven\Components\Http\Request;
use FastRaven\Components\Http\Response;

return function(Request $request): Response {
    return Response::new(true, 200, "This should give a little information.", "PONG");
};