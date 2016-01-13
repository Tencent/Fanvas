/*
* Tencent is pleased to support the open source community by making Fanvas available.
* Copyright (C) 2015 THL A29 Limited, a Tencent company. All rights reserved.
*
* Licensed under the MIT License (the "License"); you may not use this file except in compliance with the 
* License. You may obtain a copy of the License at
* http://opensource.org/licenses/MIT
*
* Unless required by applicable law or agreed to in writing, software distributed under the License is 
* distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
* implied. See the License for the specific language governing permissions and limitations under the 
* License.
*/
package model.frameAction {
	import model.InstanceData;
	import model.TweenData;
	
	/**
	 * 实例的tween action。
	 * @author juliashen
	 * @date Jul 16, 2014
	 */
	public class TweenAction extends BaseFrameAction {
		
		public var instanceData : InstanceData;
		public var tweenData : TweenData;
		public var duration : int;
		
		public function TweenAction(instanceData : InstanceData, tweenData : TweenData, duration : int) {
			super();
			
			this.instanceData = instanceData;
			this.tweenData = tweenData;
			this.duration = duration;
		}
		
	}
}