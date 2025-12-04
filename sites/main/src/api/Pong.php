<?php

use SmartGoblin\Components\Http\Request;
use SmartGoblin\Components\Http\Response;

return function(Request $request): Response {
    return Response::new(true, 200, "This should give a little information.", "PONG");
};