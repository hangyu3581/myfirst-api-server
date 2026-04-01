import { createRouter, createWebHistory } from 'vue-router'
import UserView from '../views/UserView.vue'

const routes = [
  { path: '/', component: UserView }
]

export default createRouter({
  history: createWebHistory(),
  routes
})
